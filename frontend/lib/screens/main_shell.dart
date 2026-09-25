import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'add_expense_screen.dart';
import 'dashboard_screen.dart';
import 'expense_history_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();
  final GlobalKey<ExpenseHistoryScreenState> _historyKey = GlobalKey<ExpenseHistoryScreenState>();
  final GlobalKey<ReportsScreenState> _reportsKey = GlobalKey<ReportsScreenState>();

  void _onTabTapped(int index) {
    if (index == 2) {
      // "+ Add" button in middle opens AddExpenseScreen
      _openAddExpense();
    } else {
      setState(() {
        _currentIndex = index;
      });

      // Trigger refresh on the newly active tab
      if (index == 0) {
        _dashboardKey.currentState?.refreshData();
      } else if (index == 1) {
        _historyKey.currentState?.refreshData();
      } else if (index == 3) {
        _reportsKey.currentState?.refreshData();
      }
    }
  }

  Future<void> _openAddExpense() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );

    if (result == true) {
      _dashboardKey.currentState?.refreshData();
      _historyKey.currentState?.refreshData();
      _reportsKey.currentState?.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        key: _dashboardKey,
        onNavigateTab: (idx) => _onTabTapped(idx),
      ),
      ExpenseHistoryScreen(key: _historyKey),
      const SizedBox.shrink(), // Placeholder for index 2 (Add)
      ReportsScreen(key: _reportsKey),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppConstants.primaryGreen,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 8,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppConstants.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
            label: 'Add',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics_rounded),
            label: 'Reports',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
