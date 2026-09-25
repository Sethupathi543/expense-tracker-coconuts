import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/report_item.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import '../widgets/category_icon.dart';
import 'coconut/coconut_analyzer_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => ReportsScreenState();
}

class ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ExpenseService _expenseService = ExpenseService();

  bool _isLoading = true;
  String? _errorMessage;

  List<CategoryReportItem> _categoryReports = [];
  List<DailyReportItem> _dailyReports = [];
  List<DailyReportItem> _weeklyReports = [];
  List<DailyReportItem> _monthlyReports = [];

  double _categoryTotal = 0.0;
  double _dailyTotal = 0.0;
  double _weeklyTotal = 0.0;
  double _monthlyTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void refreshData() {
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final catReport = await _expenseService.getCategoryWiseReport();
      final dailyReport = await _expenseService.getDailyReport();
      final weeklyReport = await _expenseService.getWeeklyReport();
      final monthlyReport = await _expenseService.getMonthlyReport();

      if (mounted) {
        setState(() {
          _categoryReports = catReport;
          _dailyReports = dailyReport;
          _weeklyReports = weeklyReport;
          _monthlyReports = monthlyReport;

          _categoryTotal = catReport.fold(0.0, (sum, i) => sum + i.totalAmount);
          _dailyTotal = dailyReport.fold(0.0, (sum, i) => sum + i.totalAmount);
          _weeklyTotal = weeklyReport.fold(0.0, (sum, i) => sum + i.totalAmount);
          _monthlyTotal = monthlyReport.fold(0.0, (sum, i) => sum + i.totalAmount);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryGreen,
        elevation: 0,
        title: const Text(
          'Expense Reports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Category'),
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryGreen))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadReports, child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCategoryTab(),
                    _buildDailyTab(),
                    _buildWeeklyTab(),
                    _buildMonthlyTab(),
                  ],
                ),
    );
  }

  Widget _buildCategoryTab() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.currency,
      decimalDigits: 0,
    );

    if (_categoryReports.isEmpty) {
      return _buildEmptyState('No category expenses to report yet');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coconut Analyzer Quick Banner (All Buying & Selling)
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoconutAnalyzerScreen()),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppConstants.coconutBrown, Color(0xFF3E2723)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Text('🥥', style: TextStyle(fontSize: 26)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coconut Category: Buying & Selling Analyzer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'All Farmers, Traders, Byproducts & Coconut expenses organized by Date, Week & Month',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.amberAccent, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Total Spent Header
          _buildTotalCard('Total Categorized Expenses', _categoryTotal),
          const SizedBox(height: 20),

          // Pie Chart representation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                const Text(
                  'Expenditure Distribution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textDark),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _categoryReports.map((item) {
                        final color = AppConstants.getCategoryColor(item.category);
                        return PieChartSectionData(
                          color: color,
                          value: item.totalAmount,
                          title: '${item.percentage.toStringAsFixed(1)}%',
                          radius: 54,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Breakdown by Category',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppConstants.textDark),
          ),
          const SizedBox(height: 10),

          // List of category rows
          ..._categoryReports.map((item) {
            final color = AppConstants.getCategoryColor(item.category);
            final isCoconut = item.category.toLowerCase() == 'coconut';

            return InkWell(
              onTap: isCoconut
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CoconutAnalyzerScreen()),
                      );
                    }
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.12),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCoconut ? AppConstants.coconutBrown : color.withValues(alpha: 0.35),
                    width: isCoconut ? 1.8 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left vertical color accent bar
                        Container(
                          width: 6,
                          color: color,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CategoryIconWidget(category: item.category, size: 44, iconSize: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                item.category,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: color,
                                                ),
                                              ),
                                              if (isCoconut) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppConstants.coconutBrown.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: const Text(
                                                    'Analyzer 🥥',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppConstants.coconutBrown,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.count} ${item.count == 1 ? "expense" : "expenses"}',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          currencyFormatter.format(item.totalAmount),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AppConstants.textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.18),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${item.percentage.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: item.percentage / 100.0,
                                    backgroundColor: color.withValues(alpha: 0.15),
                                    valueColor: AlwaysStoppedAnimation<Color>(color),
                                    minHeight: 7,
                                  ),
                                ),
                                if (isCoconut) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppConstants.coconutBrown.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.analytics_outlined, size: 14, color: AppConstants.coconutBrown),
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Tap to view all Buying & Selling (Farmers, Traders, Byproducts)',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppConstants.coconutBrown,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppConstants.coconutBrown),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDailyTab() {
    return _buildTimeReportView(
      title: 'Daily Report (Last 30 Days)',
      total: _dailyTotal,
      items: _dailyReports,
      emptyMessage: 'No daily expenses found for the selected period',
    );
  }

  Widget _buildWeeklyTab() {
    return _buildTimeReportView(
      title: 'Current Week Expenses',
      total: _weeklyTotal,
      items: _weeklyReports,
      emptyMessage: 'No expenses recorded this week',
    );
  }

  Widget _buildMonthlyTab() {
    return _buildTimeReportView(
      title: 'Current Month Expenses',
      total: _monthlyTotal,
      items: _monthlyReports,
      emptyMessage: 'No expenses recorded this month',
    );
  }

  Widget _buildTimeReportView({
    required String title,
    required double total,
    required List<DailyReportItem> items,
    required String emptyMessage,
  }) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.currency,
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('dd MMM yyyy');

    if (items.isEmpty) {
      return _buildEmptyState(emptyMessage);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalCard(title, total),
          const SizedBox(height: 20),

          // Daily records list
          const Text(
            'Daily Records',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppConstants.textDark),
          ),
          const SizedBox(height: 10),

          ...items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryGreen.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_note, color: AppConstants.primaryGreen, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        dateFormatter.format(item.date),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textDark,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currencyFormatter.format(item.totalAmount),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textDark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotalCard(String title, double amount) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.currency,
      decimalDigits: 0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryGreen.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            currencyFormatter.format(amount),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
