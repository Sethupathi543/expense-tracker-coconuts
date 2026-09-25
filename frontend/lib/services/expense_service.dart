import 'dart:convert';
import '../models/dashboard_summary.dart';
import '../models/expense.dart';
import '../models/report_item.dart';
import 'api_service.dart';

class ExpenseService {
  final ApiService _apiService = ApiService();

  Future<Expense> createExpense(Expense expense) async {
    final response = await _apiService.post('/expenses', expense.toJson());
    if (response.statusCode == 200 || response.statusCode == 201) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to add expense');
    }
  }

  Future<List<Expense>> getExpenses({
    String? search,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (category != null && category.isNotEmpty && category != 'All') queryParams['category'] = category;
    if (startDate != null) {
      queryParams['startDate'] = "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    }
    if (endDate != null) {
      queryParams['endDate'] = "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
    }

    final response = await _apiService.get('/expenses', queryParams: queryParams);
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Expense.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load expenses');
    }
  }

  Future<Expense> getExpenseById(int id) async {
    final response = await _apiService.get('/expenses/$id');
    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Expense not found');
    }
  }

  Future<Expense> updateExpense(int id, Expense expense) async {
    final response = await _apiService.put('/expenses/$id', expense.toJson());
    if (response.statusCode == 200) {
      return Expense.fromJson(jsonDecode(response.body));
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to update expense');
    }
  }

  Future<void> deleteExpense(int id) async {
    final response = await _apiService.delete('/expenses/$id');
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to delete expense');
    }
  }

  Future<DashboardSummary> getDashboardSummary() async {
    final response = await _apiService.get('/dashboard/summary');
    if (response.statusCode == 200) {
      return DashboardSummary.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard summary');
    }
  }

  Future<List<CategoryReportItem>> getCategoryWiseReport() async {
    final response = await _apiService.get('/reports/category-wise');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List rawList = data['data'] ?? [];
      return rawList.map((e) => CategoryReportItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load category report');
    }
  }

  Future<List<DailyReportItem>> getDailyReport({DateTime? startDate, DateTime? endDate}) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) {
      queryParams['startDate'] = "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
    }
    if (endDate != null) {
      queryParams['endDate'] = "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";
    }

    final response = await _apiService.get('/reports/daily', queryParams: queryParams);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List rawList = data['data'] ?? [];
      return rawList.map((e) => DailyReportItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load daily report');
    }
  }

  Future<List<DailyReportItem>> getWeeklyReport() async {
    final response = await _apiService.get('/reports/weekly');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List rawList = data['data'] ?? [];
      return rawList.map((e) => DailyReportItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load weekly report');
    }
  }

  Future<List<DailyReportItem>> getMonthlyReport({int? year, int? month}) async {
    final queryParams = <String, dynamic>{};
    if (year != null) queryParams['year'] = year;
    if (month != null) queryParams['month'] = month;

    final response = await _apiService.get('/reports/monthly', queryParams: queryParams);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List rawList = data['data'] ?? [];
      return rawList.map((e) => DailyReportItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load monthly report');
    }
  }
}
