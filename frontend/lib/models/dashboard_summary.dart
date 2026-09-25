import 'expense.dart';

class DashboardSummary {
  final double todayExpense;
  final double thisWeekExpense;
  final double thisMonthExpense;
  final List<Expense> recentExpenses;

  DashboardSummary({
    required this.todayExpense,
    required this.thisWeekExpense,
    required this.thisMonthExpense,
    required this.recentExpenses,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    var rawList = json['recentExpenses'] as List? ?? [];
    List<Expense> expenses = rawList.map((e) => Expense.fromJson(e)).toList();

    return DashboardSummary(
      todayExpense: (json['todayExpense'] as num?)?.toDouble() ?? 0.0,
      thisWeekExpense: (json['thisWeekExpense'] as num?)?.toDouble() ?? 0.0,
      thisMonthExpense: (json['thisMonthExpense'] as num?)?.toDouble() ?? 0.0,
      recentExpenses: expenses,
    );
  }
}
