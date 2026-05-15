import 'package:expense_tracker/screens/history_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/navigation/nav_item.dart';
import 'add_expense_screen.dart';
import 'dashboard_screen.dart';
import 'home_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AddExpenseScreen(),
    DashboardScreen(),
    HistoryScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black.withOpacity(0.08), width: 0.5),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                NavItem(
                  icon: Icons.history,
                  label: 'History',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),

                NavItem(
                  icon: Icons.add,
                  label: 'Add',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                // _AddButton(onTap: () => setState(() => _currentIndex = 1)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Home Page Content ────────────────────────────────────────────────────────
