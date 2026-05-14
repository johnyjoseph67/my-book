import 'package:expense_tracker/screens/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/expense_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/expense_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.dark,
        title: const Text('History'),
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
          final data = provider.expenses
              .where((e) => e.emailId == AppConstants.getEmailId());

          // final summary = provider.currentSummary;
          if (data.length.toString() == '0') {
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EmptyState(),
              ],
            );
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: provider.refreshData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── All Transactions ──────────────────────────────────────
                  // _SectionTitle('All Transactions'),
                  const SizedBox(height: 10),
                  ...provider.expenses
                      .where((e) => e.emailId == AppConstants.getEmailId())
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ExpenseTile(expense: e),
                          )),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
