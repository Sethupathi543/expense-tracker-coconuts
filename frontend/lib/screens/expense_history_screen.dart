import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import '../widgets/expense_card.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class ExpenseHistoryScreen extends StatefulWidget {
  const ExpenseHistoryScreen({super.key});

  @override
  State<ExpenseHistoryScreen> createState() => ExpenseHistoryScreenState();
}

class ExpenseHistoryScreenState extends State<ExpenseHistoryScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final TextEditingController _searchController = TextEditingController();

  List<Expense> _expenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCategory = 'All';
  String _selectedDateFilter = 'All'; // 'All', 'Today', 'Specific Date', 'Specific Month', 'This Week', 'This Month', 'Custom'
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  DateTime? _specificDate;
  DateTime? _specificMonth;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void refreshData() {
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      DateTime? start;
      DateTime? end;
      final now = DateTime.now();

      if (_selectedDateFilter == 'Today') {
        start = DateTime(now.year, now.month, now.day);
        end = DateTime(now.year, now.month, now.day);
      } else if (_selectedDateFilter == 'Specific Date' && _specificDate != null) {
        start = DateTime(_specificDate!.year, _specificDate!.month, _specificDate!.day);
        end = DateTime(_specificDate!.year, _specificDate!.month, _specificDate!.day);
      } else if (_selectedDateFilter == 'Specific Month' && _specificMonth != null) {
        start = DateTime(_specificMonth!.year, _specificMonth!.month, 1);
        end = DateTime(_specificMonth!.year, _specificMonth!.month + 1, 0);
      } else if (_selectedDateFilter == 'This Week') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        end = now;
      } else if (_selectedDateFilter == 'This Month') {
        start = DateTime(now.year, now.month, 1);
        end = now;
      } else if (_selectedDateFilter == 'Custom') {
        start = _customStartDate;
        end = _customEndDate;
      }

      final expenses = await _expenseService.getExpenses(
        search: _searchController.text.trim(),
        category: _selectedCategory == 'All' ? null : _selectedCategory,
        startDate: start,
        endDate: end,
      );

      if (mounted) {
        setState(() {
          _expenses = expenses;
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

  Future<void> _handleDelete(Expense expense) async {
    try {
      await _expenseService.deleteExpense(expense.id!);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted expense: ${expense.category} (${AppConstants.currency}${expense.amount.toStringAsFixed(0)})'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      _fetchExpenses();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _selectedDateFilter = 'Custom';
      });
      _fetchExpenses();
    }
  }

  Future<void> _selectSpecificDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _specificDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _specificDate = picked;
        _selectedDateFilter = 'Specific Date';
      });
      _fetchExpenses();
    }
  }

  Future<void> _selectSpecificMonth() async {
    int tempYear = _specificMonth?.year ?? DateTime.now().year;
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Select Month', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setDialogState(() => tempYear--);
                        },
                      ),
                      Text('$tempYear', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setDialogState(() => tempYear++);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              content: SizedBox(
                width: 320,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.8,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final isCurrentMonth = _specificMonth != null &&
                        _specificMonth!.year == tempYear &&
                        _specificMonth!.month == (index + 1);
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _specificMonth = DateTime(tempYear, index + 1, 1);
                          _selectedDateFilter = 'Specific Month';
                        });
                        _fetchExpenses();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrentMonth
                              ? AppConstants.primaryGreen
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCurrentMonth
                                ? AppConstants.primaryGreen
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            months[index].substring(0, 3),
                            style: TextStyle(
                              color: isCurrentMonth ? Colors.white : AppConstants.textDark,
                              fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.currency,
      decimalDigits: 0,
    );

    double totalFilteredAmount = _expenses.fold(0.0, (sum, item) => sum + item.amount);

    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryGreen,
        elevation: 0,
        title: const Text(
          'Expense History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add Expense',
            onPressed: () async {
              final res = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );
              if (res == true) _fetchExpenses();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Controls Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _fetchExpenses(),
                  decoration: InputDecoration(
                    hintText: 'Search note or category...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _fetchExpenses();
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Categories', _selectedCategory == 'All', () {
                        setState(() => _selectedCategory = 'All');
                        _fetchExpenses();
                      }),
                      ...AppConstants.categories.map((cat) {
                        return _buildFilterChip(cat, _selectedCategory == cat, () {
                          setState(() => _selectedCategory = cat);
                          _fetchExpenses();
                        });
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Date Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildDateChip('All Time', 'All'),
                      _buildDateChip('Today', 'Today'),
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ActionChip(
                          avatar: Icon(
                            Icons.event,
                            size: 16,
                            color: _selectedDateFilter == 'Specific Date' ? Colors.white : AppConstants.primaryGreen,
                          ),
                          label: Text(
                            _selectedDateFilter == 'Specific Date' && _specificDate != null
                                ? DateFormat('dd MMM yyyy').format(_specificDate!)
                                : 'Pick Date 📅',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedDateFilter == 'Specific Date' ? FontWeight.bold : FontWeight.normal,
                              color: _selectedDateFilter == 'Specific Date' ? Colors.white : AppConstants.textDark,
                            ),
                          ),
                          backgroundColor: _selectedDateFilter == 'Specific Date'
                              ? AppConstants.primaryGreen
                              : Colors.grey.shade100,
                          onPressed: _selectSpecificDate,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: ActionChip(
                          avatar: Icon(
                            Icons.calendar_month,
                            size: 16,
                            color: _selectedDateFilter == 'Specific Month' ? Colors.white : AppConstants.primaryGreen,
                          ),
                          label: Text(
                            _selectedDateFilter == 'Specific Month' && _specificMonth != null
                                ? DateFormat('MMM yyyy').format(_specificMonth!)
                                : 'Pick Month 🗓️',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _selectedDateFilter == 'Specific Month' ? FontWeight.bold : FontWeight.normal,
                              color: _selectedDateFilter == 'Specific Month' ? Colors.white : AppConstants.textDark,
                            ),
                          ),
                          backgroundColor: _selectedDateFilter == 'Specific Month'
                              ? AppConstants.primaryGreen
                              : Colors.grey.shade100,
                          onPressed: _selectSpecificMonth,
                        ),
                      ),
                      _buildDateChip('This Week', 'This Week'),
                      _buildDateChip('This Month', 'This Month'),
                      ActionChip(
                        avatar: const Icon(Icons.date_range, size: 16, color: AppConstants.primaryGreen),
                        label: Text(
                          _selectedDateFilter == 'Custom' && _customStartDate != null && _customEndDate != null
                              ? '${DateFormat('dd MMM').format(_customStartDate!)} - ${DateFormat('dd MMM').format(_customEndDate!)}'
                              : 'Custom Range',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _selectedDateFilter == 'Custom' ? FontWeight.bold : FontWeight.normal,
                            color: _selectedDateFilter == 'Custom' ? AppConstants.primaryGreen : AppConstants.textDark,
                          ),
                        ),
                        backgroundColor: _selectedDateFilter == 'Custom' ? AppConstants.primaryGreen.withOpacity(0.15) : Colors.grey.shade100,
                        onPressed: _selectCustomDateRange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Total Bar for active filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDateFilter == 'Specific Date' && _specificDate != null
                            ? '📅 ${DateFormat("dd MMM yyyy").format(_specificDate!)} (${_expenses.length} ${_expenses.length == 1 ? "expense" : "expenses"})'
                            : _selectedDateFilter == 'Specific Month' && _specificMonth != null
                                ? '🗓️ ${DateFormat("MMMM yyyy").format(_specificMonth!)} (${_expenses.length} ${_expenses.length == 1 ? "expense" : "expenses"})'
                                : '${_expenses.length} ${_expenses.length == 1 ? "Expense" : "Expenses"} Found',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_selectedDateFilter != 'All' || _selectedCategory != 'All')
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDateFilter = 'All';
                              _selectedCategory = 'All';
                              _specificDate = null;
                              _specificMonth = null;
                              _customStartDate = null;
                              _customEndDate = null;
                            });
                            _fetchExpenses();
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              '✕ Reset to all expenses',
                              style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  'Total: ${currencyFormatter.format(totalFilteredAmount)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryGreen,
                  ),
                ),
              ],
            ),
          ),

          // Expenses List or States
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchExpenses,
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
                                Text(_errorMessage!, textAlign: TextAlign.center),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchExpenses,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _expenses.isEmpty
                          ? ListView(
                              children: [
                                const SizedBox(height: 60),
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No matching expenses found',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textDark),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Try adjusting your search query or filters',
                                        style: TextStyle(fontSize: 13, color: AppConstants.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: _expenses.length,
                              itemBuilder: (ctx, index) {
                                final expense = _expenses[index];
                                return ExpenseCard(
                                  expense: expense,
                                  onEdit: () async {
                                    final updated = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => EditExpenseScreen(expense: expense),
                                      ),
                                    );
                                    if (updated == true) _fetchExpenses();
                                  },
                                  onDelete: () => _handleDelete(expense),
                                );
                              },
                            ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppConstants.primaryGreen.withOpacity(0.18),
        checkmarkColor: AppConstants.primaryGreen,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppConstants.primaryGreen : AppConstants.textDark,
        ),
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(
          color: isSelected ? AppConstants.primaryGreen : Colors.grey.shade300,
          width: 0.8,
        ),
      ),
    );
  }

  Widget _buildDateChip(String label, String value) {
    final isSelected = _selectedDateFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (sel) {
          if (sel) {
            setState(() => _selectedDateFilter = value);
            _fetchExpenses();
          }
        },
        selectedColor: AppConstants.primaryGreen.withOpacity(0.18),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppConstants.primaryGreen : AppConstants.textDark,
        ),
        backgroundColor: Colors.grey.shade100,
        side: BorderSide(
          color: isSelected ? AppConstants.primaryGreen : Colors.grey.shade300,
          width: 0.8,
        ),
      ),
    );
  }
}
