// ─── Category Pie Chart ────────────────────────────────────────────────────────

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';

class CategoryPieCard extends StatefulWidget {
  final Map<String, double> byCategory;
  const CategoryPieCard({super.key, required this.byCategory});

  @override
  State<CategoryPieCard> createState() => _CategoryPieCardState();
}

class _CategoryPieCardState extends State<CategoryPieCard> {
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
