// lib/screens/dashboard_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense_model.dart';
import '../services/expense_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/expense_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // static final _fmt = NumberFormat('#,##0.00', 'en_US');
  static final _fmtShort = NumberFormat('#,##0', 'en_US');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.dark,
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => context.read<ExpenseProvider>().refreshData(),
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.currentSummary == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          final summary = provider.currentSummary;
          if (summary == null) {
            return const Center(child: Text('No data available'));
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: provider.refreshData,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                       const SizedBox(height: 20),
                   SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      final _trend = provider.trend;
                      return GestureDetector(
                        onTap:  () => context.read<ExpenseProvider>().refreshData(year: _trend[index].year,month: _trend[index].month),
                        child: Container(
                          decoration: BoxDecoration(color: AppTheme.primary,borderRadius: BorderRadius.circular(10)),
                          height: 20,width: 80,
                          child: Center(child: Text(_trend[index].monthName,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(width: 10,);
                    },
                    itemCount: provider.trend.length),
              ),
                const SizedBox(height: 10),
                 _SectionTitle(
                              '${summary.monthName} ${summary.year} Overview'),
                                const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── KPI Row ────────────────────────────────────────────────
                         
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.7,
                            children: [
                              _KpiCard(
                                label: 'Total Spent',
                                value: 'AED ${_fmtShort.format(summary.totalSpent)}',
                                sub:
                                    '${summary.percentUsed.toStringAsFixed(1)}% of budget',
                                color: AppTheme.danger,
                              ),
                              _KpiCard(
                                label: 'Remaining',
                                value:
                                    'AED ${_fmtShort.format(summary.remaining.clamp(0, double.infinity))}',
                                sub: 'Budget: AED ${_fmtShort.format(summary.budget)}',
                                color: AppTheme.primary,
                              ),
                              _KpiCard(
                                label: 'Transactions',
                                value: '${summary.expenses.length}',
                                sub: 'this month',
                                color: AppTheme.info,
                              ),
                              _KpiCard(
                                label: 'Daily Average',
                                value:
                                    'AED ${_fmtShort.format(summary.totalSpent / DateTime.now().day)}',
                                sub: 'per day',
                                color: AppTheme.warning,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                      
                          // ── Budget Progress ────────────────────────────────────────
                          _SectionTitle('Budget Usage'),
                          const SizedBox(height: 10),
                          _BudgetProgressCard(summary: summary),
                          const SizedBox(height: 20),
                      
                          // ── Monthly Trend Bar Chart ────────────────────────────────
                          _SectionTitle('6-Month Trend'),
                          const SizedBox(height: 10),
                          _TrendChart(trend: provider.trend),
                          const SizedBox(height: 20),
                      
                          // ── Category Pie Chart ────────────────────────────────────
                          _SectionTitle('Spending by Category'),
                          const SizedBox(height: 10),
                          _CategoryPieCard(byCategory: summary.byCategory),
                          const SizedBox(height: 20),
                      
                          // ── Category Breakdown Bars ───────────────────────────────
                          _SectionTitle('Category Breakdown'),
                          const SizedBox(height: 10),
                          _CategoryBreakdown(
                            byCategory: summary.byCategory,
                            total: summary.totalSpent,
                          ),
                          // const SizedBox(height: 20),
                      
                          // ── All Transactions ──────────────────────────────────────
                          // _SectionTitle('All Transactions'),
                          // const SizedBox(height: 10),
                          // ...provider.expenses.map((e) => Padding(
                          //       padding: const EdgeInsets.only(bottom: 8),
                          //       child: ExpenseTile(expense: e),
                          //     )),
                          // const SizedBox(height: 0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Section Title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.dark,
        letterSpacing: 0.5,
      ),
    );
  }
}

// ─── KPI Card ──────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(sub,
              style:
                  const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

// ─── Budget Progress ───────────────────────────────────────────────────────────

class _BudgetProgressCard extends StatelessWidget {
  final MonthlySummary summary;
  const _BudgetProgressCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final pct = summary.percentUsed / 100;
    final color = pct > 0.9
        ? AppTheme.danger
        : pct > 0.7
            ? AppTheme.warning
            : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'AED ${NumberFormat('#,##0').format(summary.totalSpent)} spent',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text('of AED ${NumberFormat('#,##0').format(summary.budget)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.black.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${summary.percentUsed.toStringAsFixed(1)}% used',
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w600),
              ),
              Text(
                'AED ${NumberFormat('#,##0').format(summary.remaining.clamp(0, double.infinity))} remaining',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Trend Bar Chart ───────────────────────────────────────────────────────────

class _TrendChart extends StatelessWidget {
  final List<MonthlySummary> trend;
  const _TrendChart({required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) return const SizedBox.shrink();

    final maxVal =
        trend.fold<double>(0, (m, s) => s.totalSpent > m ? s.totalSpent : m);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
      ),
      child: BarChart(
        BarChartData(
          maxY: (maxVal * 1.2).ceilToDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  'AED ${NumberFormat('#,##0').format(rod.toY)}',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= trend.length) return const SizedBox();
                  return Text(
                    trend[i].monthName,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary),
                  );
                },
                reservedSize: 20,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: Color(0x0F000000),
              strokeWidth: 1,
            ),
          ),
          barGroups: trend.asMap().entries.map((e) {
            final isCurrentMonth = e.key == trend.length - 1;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.totalSpent,
                  color:
                      isCurrentMonth ? AppTheme.primary : AppTheme.primaryLight,
                  width: 28,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ─── Category Pie Chart ────────────────────────────────────────────────────────

class _CategoryPieCard extends StatefulWidget {
  final Map<String, double> byCategory;
  const _CategoryPieCard({required this.byCategory});

  @override
  State<_CategoryPieCard> createState() => _CategoryPieCardState();
}

class _CategoryPieCardState extends State<_CategoryPieCard> {
  int _touchedIndex = -1;

  static const List<Color> _chartColors = [
    AppTheme.primary,
    AppTheme.warning,
    AppTheme.info,
    AppTheme.danger,
    Color(0xFF9F77DD),
    Color(0xFFD4537E),
    Color(0xFF639922),
    Color(0xFF888780),
    Color(0xFF5DCAA5),
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.byCategory.isEmpty) return const SizedBox.shrink();

    final total = widget.byCategory.values.fold<double>(0, (s, v) => s + v);
    final entries = widget.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 160,
            width: 160,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      _touchedIndex =
                          response?.touchedSection?.touchedSectionIndex ?? -1;
                    });
                  },
                ),
                sections: entries.asMap().entries.map((e) {
                  final isTouched = e.key == _touchedIndex;
                  final pct = (e.value.value / total * 100);
                  return PieChartSectionData(
                    color: _chartColors[e.key % _chartColors.length],
                    value: e.value.value,
                    title: isTouched ? '${pct.toStringAsFixed(1)}%' : '',
                    radius: isTouched ? 70 : 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 35,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.asMap().entries.map((e) {
                final pct = (e.value.value / total * 100);
                final cat = AppConstants.categories.firstWhere(
                  (c) => c.name == e.value.key,
                  orElse: () => AppConstants.categories.last,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _chartColors[e.key % _chartColors.length],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(cat.emoji, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          e.value.key,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.dark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Breakdown Bars ───────────────────────────────────────────────────

class _CategoryBreakdown extends StatelessWidget {
  final Map<String, double> byCategory;
  final double total;

  const _CategoryBreakdown({
    required this.byCategory,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (byCategory.isEmpty) return const SizedBox.shrink();

    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06), width: 0.5),
      ),
      child: Column(
        children: sorted.map((entry) {
          final cat = AppConstants.categories.firstWhere(
            (c) => c.name == entry.key,
            orElse: () => AppConstants.categories.last,
          );
          final pct = total > 0 ? (entry.value / total) : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entry.key,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                    Text(
                      'AED ${NumberFormat('#,##0').format(entry.value)}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.toDouble(),
                    minHeight: 6,
                    backgroundColor: Colors.black.withOpacity(0.05),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(cat.color.withOpacity(1)),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
