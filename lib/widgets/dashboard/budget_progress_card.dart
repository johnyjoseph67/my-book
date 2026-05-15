// ─── Budget Progress ───────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';
import '../../utils/app_theme.dart';

class BudgetProgressCard extends StatelessWidget {
  final MonthlySummary summary;
  const BudgetProgressCard({super.key, required this.summary});

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
