// lib/widgets/balance_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../utils/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final MonthlySummary? summary;
  const BalanceCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final pct = s?.percentUsed ?? 0;
    final color = pct > 90
        ? AppTheme.danger
        : pct > 70
            ? AppTheme.warning
            : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Spent',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                  letterSpacing: 0.3)),
          const SizedBox(height: 6),
          Text(
            s != null
                ? 'AED ${NumberFormat('#,##0.00').format(s.totalSpent)}'
                : 'Loading...',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (s != null) ...[
            const SizedBox(height: 4),
            Text(
              'Budget: AED ${NumberFormat('#,##0').format(s.budget)}  ·  ${s.percentUsed.toStringAsFixed(1)}% used',
              style: const TextStyle(fontSize: 11, color: Colors.white60),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (s.percentUsed / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Pill('+${s.expenses.length} entries'),
                const SizedBox(width: 8),
                _Pill('AED ${NumberFormat('#,##0').format(s.remaining.clamp(0, double.infinity))} left'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 11, color: Colors.white)),
    );
  }
}
