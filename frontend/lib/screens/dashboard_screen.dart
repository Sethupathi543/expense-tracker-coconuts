import 'package:flutter/material.dart';
import '../models/dashboard_summary.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import '../widgets/expense_card.dart';
import '../widgets/summary_card.dart';
import 'add_expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final AuthService _authService = AuthService();

  DashboardSummary? _summary;
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getSavedUser();
      final summary = await _expenseService.getDashboardSummary();

      if (mounted) {
        setState(() {
          _currentUser = user;
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void refreshData() {
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryGreen,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.park_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coconut Expense Tracker',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _currentUser != null ? 'Hello, ${_currentUser!.name}' : 'Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppConstants.primaryGreen,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppConstants.primaryGreen),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, color: AppConstants.textDark),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryGreen,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Expense Summary Section
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: AppConstants.primaryGreen,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "EXPENSE SUMMARY",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Highlight: Today's Expense
                              SummaryCard(
                                title: "Today's Expense",
                                amount: _summary?.todayExpense ?? 0.0,
                                icon: Icons.today_rounded,
                                color: Colors.white,
                                isPrimary: true,
                              ),
                              const SizedBox(height: 10),
                              // 2 Columns: This Week & This Month
                              Row(
                                children: [
                                  Expanded(
                                    child: SummaryCard(
                                      title: 'This Week',
                                      amount: _summary?.thisWeekExpense ?? 0.0,
                                      icon: Icons.date_range_rounded,
                                      color: AppConstants.accentAmber,
                                      isPrimary: false,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: SummaryCard(
                                      title: 'This Month',
                                      amount: _summary?.thisMonthExpense ?? 0.0,
                                      icon: Icons.calendar_month_rounded,
                                      color: AppConstants.primaryGreen,
                                      isPrimary: false,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Action Banner: + Add Expense
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final added = await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                              );
                              if (added == true) {
                                _loadData();
                              }
                            },
                            icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                            label: const Text(
                              '+ Add Expense',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.primaryGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Recent Expenses Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Expenses',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.textDark,
                                ),
                              ),
                              if ((_summary?.recentExpenses.length ?? 0) > 0)
                                TextButton(
                                  onPressed: () {
                                    if (widget.onNavigateTab != null) {
                                      widget.onNavigateTab!(1); // Go to Expenses tab
                                    }
                                  },
                                  child: const Text(
                                    'View All',
                                    style: TextStyle(
                                      color: AppConstants.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Recent Expenses List or Empty State
                        if (_summary == null || _summary!.recentExpenses.isEmpty)
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 54,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No expenses recorded yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppConstants.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Tap "+ Add Expense" above to record your first daily expense.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13, color: AppConstants.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _summary!.recentExpenses.length,
                            itemBuilder: (ctx, index) {
                              final exp = _summary!.recentExpenses[index];
                              return ExpenseCard(expense: exp);
                            },
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
