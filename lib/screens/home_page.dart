import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/expense_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/category_grid.dart';
import '../widgets/expense_tile.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/empty_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => context.read<ExpenseProvider>().refreshData(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              backgroundColor: AppTheme.dark,
              title: Consumer<ExpenseProvider>(builder: (_, provider, __) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_greeting()}!',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }),
            ),
            SliverToBoxAdapter(
              child: Consumer<ExpenseProvider>(
                builder: (_, provider, __) {
                  if (provider.isLoading && provider.currentSummary == null) {
                    return const SizedBox(
                      height: 400,
                      child: Center(
                        child:
                            CircularProgressIndicator(color: AppTheme.primary),
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance card
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: BalanceCard(summary: provider.currentSummary),
                      ),

                      // Categories
                      const Padding(
                        padding: EdgeInsets.only(left: 20, bottom: 10),
                        child: Text(
                          'CATEGORIES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const CategoryGrid(),

                      // Recent transactions
                      const Padding(
                        padding: EdgeInsets.only(left: 20, top: 8, bottom: 10),
                        child: Text(
                          'RECENT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (provider.recentExpenses
                          .where((e) => e.emailId == AppConstants.getEmailId())
                          .toList()
                          .isEmpty)
                        const EmptyState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.recentExpenses
                              .where(
                                  (e) => e.emailId == AppConstants.getEmailId())
                              .length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) =>
                              ExpenseTile(expense: provider.recentExpenses[i]),
                        ),
                      const SizedBox(height: 100),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}
