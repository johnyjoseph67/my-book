// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/expense_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/dashboard/budget_progress_card.dart';
import '../widgets/dashboard/category_break_down.dart';
import '../widgets/dashboard/category_pie_chart.dart';
import '../widgets/dashboard/k_pei_card.dart';
import '../widgets/dashboard/section_tile.dart';
import '../widgets/dashboard/trend_chart.dart';

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
                          final trend = provider.trend;
                          return GestureDetector(
                            onTap: () => context
                                .read<ExpenseProvider>()
                                .refreshData(
                                    year: trend[index].year,
                                    month: trend[index].month),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(10)),
                              height: 20,
                              width: 80,
                              child: Center(
                                child: Text(
                                  trend[index].monthName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            width: 10,
                          );
                        },
                        itemCount: provider.trend.length),
                  ),
                  const SizedBox(height: 10),
                  SectionTitle('${summary.monthName} ${summary.year} Overview'),
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
                              KpiCard(
                                label: 'Total Spent',
                                value:
                                    'AED ${_fmtShort.format(summary.totalSpent)}',
                                sub:
                                    '${summary.percentUsed.toStringAsFixed(1)}% of budget',
                                color: AppTheme.danger,
                              ),
                              KpiCard(
                                label: 'Remaining',
                                value:
                                    'AED ${_fmtShort.format(summary.remaining.clamp(0, double.infinity))}',
                                sub:
                                    'Budget: AED ${_fmtShort.format(summary.budget)}',
                                color: AppTheme.primary,
                              ),
                              KpiCard(
                                label: 'Transactions',
                                value: '${summary.expenses.length}',
                                sub: 'this month',
                                color: AppTheme.info,
                              ),
                              KpiCard(
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
                          const SectionTitle('Budget Usage'),
                          const SizedBox(height: 10),
                          BudgetProgressCard(summary: summary),
                          const SizedBox(height: 20),

                          // ── Monthly Trend Bar Chart ────────────────────────────────
                          const SectionTitle('6-Month Trend'),
                          const SizedBox(height: 10),
                          TrendChart(trend: provider.trend),
                          const SizedBox(height: 20),

                          // ── Category Pie Chart ────────────────────────────────────
                          const SectionTitle('Spending by Category'),
                          const SizedBox(height: 10),
                          CategoryPieCard(byCategory: summary.byCategory),
                          const SizedBox(height: 20),

                          // ── Category Breakdown Bars ───────────────────────────────
                          const SectionTitle('Category Breakdown'),
                          const SizedBox(height: 10),
                          CategoryBreakdown(
                            byCategory: summary.byCategory,
                            total: summary.totalSpent,
                          ),
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
