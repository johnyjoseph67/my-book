// ─── Category Breakdown Bars ───────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../utils/app_theme.dart';

class CategoryBreakdown extends StatelessWidget {
  final Map<String, double> byCategory;
  final double total;

  const CategoryBreakdown({
    super.key,
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
