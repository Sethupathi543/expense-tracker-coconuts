import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../models/farmer.dart';
import '../../models/trader.dart';
import '../../models/resource_earning.dart';
import '../../services/coconut_business_service.dart';
import '../../services/expense_service.dart';
import '../../utils/constants.dart';
import '../../widgets/receipt_dialog.dart';
import '../add_expense_screen.dart';
import 'farmer/farmer_list_screen.dart';
import 'trader/trader_list_screen.dart';
import 'add_resource_earning_screen.dart';

enum CoconutEntryType { buying, selling }

enum CoconutSourceType { farmer, trader, byproduct, expense }

class UnifiedCoconutEntry {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final CoconutEntryType type;
  final CoconutSourceType source;
  final String? paymentMethod;
  final String? note;
  final String? partyName;
  final String iconEmoji;
  final Color themeColor;
  final Expense asExpense;

  UnifiedCoconutEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    required this.source,
    this.paymentMethod,
    this.note,
    this.partyName,
    required this.iconEmoji,
    required this.themeColor,
    required this.asExpense,
  });
}

class CoconutAnalyzerScreen extends StatefulWidget {
  const CoconutAnalyzerScreen({super.key});

  @override
  State<CoconutAnalyzerScreen> createState() => _CoconutAnalyzerScreenState();
}

class _CoconutAnalyzerScreenState extends State<CoconutAnalyzerScreen>
    with SingleTickerProviderStateMixin {
  final ExpenseService _expenseService = ExpenseService();
  final CoconutBusinessService _coconutService = CoconutBusinessService();
  late TabController _tabController;

  List<UnifiedCoconutEntry> _allEntries = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter state
  String _flowFilter = 'All'; // 'All', 'Buying', 'Selling'
  String _sourceFilter = 'All'; // 'All', 'Farmer', 'Trader', 'Byproduct', 'Expense'

  // Date Filter State
  DateTime _selectedDate = DateTime.now();

  // Weekly Filter State (Monday of current week)
  late DateTime _selectedWeekStart;

  // Monthly Filter State
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final now = DateTime.now();
    _selectedWeekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    _loadAllCoconutData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllCoconutData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch all sources of coconut data in parallel
      final results = await Future.wait([
        _expenseService.getExpenses(category: 'Coconut'),
        _coconutService.getAllFarmerTransactions(),
        _coconutService.getFarmers(),
        _coconutService.getAllTraderTransactions(),
        _coconutService.getTraders(),
        _coconutService.getResourceEarnings(),
      ]);

      final expenses = results[0] as List<Expense>;
      final farmerTxs = results[1] as List<FarmerTransaction>;
      final farmers = results[2] as List<Farmer>;
      final traderTxs = results[3] as List<TraderTransaction>;
      final traders = results[4] as List<Trader>;
      final byproducts = results[5] as List<ResourceEarning>;

      final List<UnifiedCoconutEntry> entries = [];

      // 1. General Coconut Expenses (Buying / Spending)
      for (final exp in expenses) {
        entries.add(
          UnifiedCoconutEntry(
            id: 'exp-${exp.id}',
            title: 'Coconut Expense',
            subtitle: exp.note.isNotEmpty ? exp.note : 'Direct Coconut Expense',
            amount: exp.amount,
            date: exp.date,
            type: CoconutEntryType.buying,
            source: CoconutSourceType.expense,
            paymentMethod: exp.paymentMethod,
            note: exp.note,
            iconEmoji: '🥥',
            themeColor: const Color(0xFFE65100),
            asExpense: exp,
          ),
        );
      }

      // 2. Farmer Transactions (Buying / Money Given to Farmers)
      final Set<int> farmersWithTx = {};
      for (final tx in farmerTxs) {
        farmersWithTx.add(tx.farmerId);
        entries.add(
          UnifiedCoconutEntry(
            id: 'farmer-tx-${tx.id}',
            title: 'Farmer Payment: ${tx.farmerName}',
            subtitle: 'Coconut Purchase Payment',
            amount: tx.amountGiven,
            date: tx.date,
            type: CoconutEntryType.buying,
            source: CoconutSourceType.farmer,
            paymentMethod: tx.paymentMethod ?? 'Cash',
            note: tx.note,
            partyName: tx.farmerName,
            iconEmoji: '🌾',
            themeColor: const Color(0xFF388E3C),
            asExpense: Expense(
              id: tx.id,
              amount: tx.amountGiven,
              category: 'Coconut (Farmer Payment)',
              date: tx.date,
              paymentMethod: tx.paymentMethod ?? 'Cash',
              note: 'Payment given to Farmer ${tx.farmerName}${tx.note != null ? " - ${tx.note}" : ""}',
            ),
          ),
        );
      }

      // If a farmer has totalPurchaseAmount > 0 and NO transactions yet, include purchase record
      for (final f in farmers) {
        if (!farmersWithTx.contains(f.id) && f.totalPurchaseAmount > 0) {
          entries.add(
            UnifiedCoconutEntry(
              id: 'farmer-init-${f.id}',
              title: 'Coconut Purchase: ${f.name}',
              subtitle: 'Initial Purchase Agreement',
              amount: f.totalPurchaseAmount,
              date: f.createdAt,
              type: CoconutEntryType.buying,
              source: CoconutSourceType.farmer,
              paymentMethod: 'Credit / Due',
              note: f.note ?? 'Purchase of coconuts from farmer',
              partyName: f.name,
              iconEmoji: '🌾',
              themeColor: const Color(0xFF2E7D32),
              asExpense: Expense(
                id: f.id,
                amount: f.totalPurchaseAmount,
                category: 'Coconut (Farmer Purchase)',
                date: f.createdAt,
                paymentMethod: 'Credit / Due',
                note: 'Coconut Purchase from ${f.name}${f.note != null ? " - ${f.note}" : ""}',
              ),
            ),
          );
        }
      }

      // 3. Trader Transactions (Selling / Collections received from Traders)
      final Set<int> tradersWithTx = {};
      for (final tx in traderTxs) {
        tradersWithTx.add(tx.traderId);
        entries.add(
          UnifiedCoconutEntry(
            id: 'trader-tx-${tx.id}',
            title: 'Trader Collection: ${tx.traderName}',
            subtitle: 'Coconut Sale Revenue Received',
            amount: tx.amountReceived,
            date: tx.date,
            type: CoconutEntryType.selling,
            source: CoconutSourceType.trader,
            paymentMethod: tx.paymentMethod ?? 'Cash',
            note: tx.note,
            partyName: tx.traderName,
            iconEmoji: '🛒',
            themeColor: AppConstants.coconutBrown,
            asExpense: Expense(
              id: tx.id,
              amount: tx.amountReceived,
              category: 'Coconut (Trader Collection)',
              date: tx.date,
              paymentMethod: tx.paymentMethod ?? 'Cash',
              note: 'Payment received from Trader ${tx.traderName}${tx.note != null ? " - ${tx.note}" : ""}',
            ),
          ),
        );
      }

      // If a trader has totalSaleAmount > 0 and NO transactions yet, include sale agreement
      for (final t in traders) {
        if (!tradersWithTx.contains(t.id) && t.totalSaleAmount > 0) {
          entries.add(
            UnifiedCoconutEntry(
              id: 'trader-init-${t.id}',
              title: 'Coconut Sale: ${t.name}',
              subtitle: 'Initial Sale Agreement',
              amount: t.totalSaleAmount,
              date: t.createdAt,
              type: CoconutEntryType.selling,
              source: CoconutSourceType.trader,
              paymentMethod: 'Pending Collection',
              note: t.note ?? 'Sale of coconuts to trader',
              partyName: t.name,
              iconEmoji: '🛒',
              themeColor: AppConstants.coconutBrown,
              asExpense: Expense(
                id: t.id,
                amount: t.totalSaleAmount,
                category: 'Coconut (Trader Sale)',
                date: t.createdAt,
                paymentMethod: 'Pending Collection',
                note: 'Coconut Sale to ${t.name}${t.note != null ? " - ${t.note}" : ""}',
              ),
            ),
          );
        }
      }

      // 4. Byproduct Sales (Selling: Thotti, Mattai, Paruppu)
      for (final bp in byproducts) {
        final typeLower = bp.resourceType.toLowerCase();
        final String emoji = typeLower == 'mattai'
            ? '🌴'
            : (typeLower == 'paruppu' ? '🥥' : '🥥');
        final Color col = typeLower == 'mattai'
            ? const Color(0xFFD84315)
            : (typeLower == 'paruppu' ? const Color(0xFF2E7D32) : const Color(0xFF6D4C41));

        final qtyStr = bp.quantity != null
            ? '${bp.quantity} ${bp.unit ?? ""}'
            : '';

        entries.add(
          UnifiedCoconutEntry(
            id: 'bp-${bp.id}',
            title: '${bp.resourceType} Sale',
            subtitle: 'Byproduct ($qtyStr)${bp.buyerName != null ? " to ${bp.buyerName}" : ""}',
            amount: bp.totalAmount,
            date: bp.date,
            type: CoconutEntryType.selling,
            source: CoconutSourceType.byproduct,
            paymentMethod: bp.paymentMethod ?? 'Cash',
            note: bp.note,
            partyName: bp.buyerName,
            iconEmoji: emoji,
            themeColor: col,
            asExpense: Expense(
              id: bp.id,
              amount: bp.totalAmount,
              category: 'Coconut (${bp.resourceType} Sale)',
              date: bp.date,
              paymentMethod: bp.paymentMethod ?? 'Cash',
              note: '${bp.resourceType} Sale${bp.buyerName != null ? " to ${bp.buyerName}" : ""}${bp.note != null ? " - ${bp.note}" : ""}',
            ),
          ),
        );
      }

      // Sort newest first
      entries.sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _allEntries = entries;
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

  // Filter helper
  List<UnifiedCoconutEntry> _applyFilter(List<UnifiedCoconutEntry> list) {
    return list.where((e) {
      if (_flowFilter == 'Buying' && e.type != CoconutEntryType.buying) return false;
      if (_flowFilter == 'Selling' && e.type != CoconutEntryType.selling) return false;

      if (_sourceFilter == 'Farmer' && e.source != CoconutSourceType.farmer) return false;
      if (_sourceFilter == 'Trader' && e.source != CoconutSourceType.trader) return false;
      if (_sourceFilter == 'Byproduct' && e.source != CoconutSourceType.byproduct) return false;
      if (_sourceFilter == 'Expense' && e.source != CoconutSourceType.expense) return false;

      return true;
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    // Total buying vs selling across all entries
    final totalAllBuying = _allEntries
        .where((e) => e.type == CoconutEntryType.buying)
        .fold<double>(0.0, (s, e) => s + e.amount);

    final totalAllSelling = _allEntries
        .where((e) => e.type == CoconutEntryType.selling)
        .fold<double>(0.0, (s, e) => s + e.amount);

    final netAllProfit = totalAllSelling - totalAllBuying;

    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Coconut Category Analyzer',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 17),
        ),
        backgroundColor: AppConstants.coconutBrown,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh All Coconut Data',
            onPressed: _loadAllCoconutData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          labelColor: Colors.amberAccent,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.calendar_today_rounded, size: 18), text: 'By Date'),
            Tab(icon: Icon(Icons.date_range_rounded, size: 18), text: 'Weekly'),
            Tab(icon: Icon(Icons.calendar_month_rounded, size: 18), text: 'Monthly'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppConstants.coconutBrown,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Coconut Entry', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: _showAddOptionsModal,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppConstants.coconutBrown),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : Column(
                  children: [
                    // Global Quick Totals & Filter Bar
                    _buildHeaderSummaryAndFilters(totalAllBuying, totalAllSelling, netAllProfit),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDateAnalyzerTab(),
                          _buildWeeklyAnalyzerTab(),
                          _buildMonthlyAnalyzerTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildHeaderSummaryAndFilters(
      double totalBuying, double totalSelling, double netProfit) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          // Filter Chips Row (Buying vs Selling vs All)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildChoiceChip('All Coconut Data', 'All', _flowFilter, (val) {
                  setState(() => _flowFilter = val);
                }),
                const SizedBox(width: 8),
                _buildChoiceChip('🛒 Buying (Purchases & Spend)', 'Buying', _flowFilter, (val) {
                  setState(() => _flowFilter = val);
                }, activeColor: const Color(0xFFD84315)),
                const SizedBox(width: 8),
                _buildChoiceChip('💰 Selling (Sales & Income)', 'Selling', _flowFilter, (val) {
                  setState(() => _flowFilter = val);
                }, activeColor: const Color(0xFF2E7D32)),
                const SizedBox(width: 12),
                Container(height: 20, width: 1, color: Colors.grey.shade300),
                const SizedBox(width: 12),
                // Source Filters
                _buildChoiceChip('🌾 Farmers', 'Farmer', _sourceFilter, (val) {
                  setState(() => _sourceFilter = _sourceFilter == val ? 'All' : val);
                }),
                const SizedBox(width: 6),
                _buildChoiceChip('🛒 Traders', 'Trader', _sourceFilter, (val) {
                  setState(() => _sourceFilter = _sourceFilter == val ? 'All' : val);
                }),
                const SizedBox(width: 6),
                _buildChoiceChip('🌴 Byproducts', 'Byproduct', _sourceFilter, (val) {
                  setState(() => _sourceFilter = _sourceFilter == val ? 'All' : val);
                }),
                const SizedBox(width: 6),
                _buildChoiceChip('🥥 Expenses', 'Expense', _sourceFilter, (val) {
                  setState(() => _sourceFilter = _sourceFilter == val ? 'All' : val);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(
    String label,
    String value,
    String currentValue,
    ValueChanged<String> onSelected, {
    Color? activeColor,
  }) {
    final isSelected = currentValue == value;
    final themeCol = activeColor ?? AppConstants.coconutBrown;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: themeCol,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppConstants.textDark,
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (_) => onSelected(value),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Failed to load coconut data',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAllCoconutData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.coconutBrown),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: BY DATE ANALYZER
  // ==========================================
  Widget _buildDateAnalyzerTab() {
    final dayEntries = _applyFilter(
      _allEntries.where((e) => _isSameDay(e.date, _selectedDate)).toList(),
    );

    final dayBuying = dayEntries
        .where((e) => e.type == CoconutEntryType.buying)
        .fold<double>(0.0, (s, e) => s + e.amount);

    final daySelling = dayEntries
        .where((e) => e.type == CoconutEntryType.selling)
        .fold<double>(0.0, (s, e) => s + e.amount);

    final dayNet = daySelling - dayBuying;

    return RefreshIndicator(
      onRefresh: _loadAllCoconutData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selector Bar
            _buildDateSelector(),
            const SizedBox(height: 14),

            // Hero Metric Card for Selected Date
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4E342E), Color(0xFF3E2723)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.park_rounded, color: Colors.amberAccent, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('dd MMMM yyyy').format(_selectedDate).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      if (_isSameDay(_selectedDate, DateTime.now()))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TODAY',
                            style: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Triple Stats: Buying, Selling, Net
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🛒 Buying (Spend)', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(height: 3),
                              Text(
                                _currencyFormatter.format(dayBuying),
                                style: const TextStyle(color: Colors.orangeAccent, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💰 Selling (Income)', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(height: 3),
                              Text(
                                _currencyFormatter.format(daySelling),
                                style: const TextStyle(color: Color(0xFF81C784), fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: dayNet >= 0
                          ? const Color(0xFF2E7D32).withValues(alpha: 0.25)
                          : Colors.red.shade900.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: dayNet >= 0 ? Colors.green.shade400 : Colors.red.shade400,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dayNet >= 0 ? '✨ Net Margin / Profit:' : '⚠️ Net Outflow (Pending):',
                          style: TextStyle(
                            color: dayNet >= 0 ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _currencyFormatter.format(dayNet),
                          style: TextStyle(
                            color: dayNet >= 0 ? Colors.greenAccent : Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Entries List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${dayEntries.length} ${dayEntries.length == 1 ? "Record" : "Records"} on ${DateFormat("dd MMM").format(_selectedDate)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.textDark),
                ),
                Text(
                  'Net: ${_currencyFormatter.format(dayNet)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: dayNet >= 0 ? const Color(0xFF2E7D32) : Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // List of items
            if (dayEntries.isEmpty)
              _buildDateEmptyState()
            else
              ...dayEntries.map((e) => _buildUnifiedEntryCard(e)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppConstants.coconutBrown),
            tooltip: 'Previous Day',
            onPressed: () {
              setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
            },
          ),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppConstants.coconutBrown),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEE, dd MMM yyyy').format(_selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppConstants.coconutBrown),
            tooltip: 'Next Day',
            onPressed: () {
              setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.coconutBrown,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildDateEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text('🥥🌴🌾', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            'No Coconut Buying or Selling on ${DateFormat("dd MMM yyyy").format(_selectedDate)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.textDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'No farmer purchases, trader collections, byproduct sales, or direct coconut expenses logged on this day.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _showAddOptionsModal,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Record Coconut Entry', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.coconutBrown,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: WEEKLY ANALYZER
  // ==========================================
  Widget _buildWeeklyAnalyzerTab() {
    final weekEnd = _selectedWeekStart.add(const Duration(days: 6));

    final weekEntries = _applyFilter(
      _allEntries.where((e) {
        final d = DateTime(e.date.year, e.date.month, e.date.day);
        return !d.isBefore(_selectedWeekStart) && !d.isAfter(weekEnd);
      }).toList(),
    );

    final weekBuying = weekEntries
        .where((e) => e.type == CoconutEntryType.buying)
        .fold<double>(0.0, (s, e) => s + e.amount);

    final weekSelling = weekEntries
        .where((e) => e.type == CoconutEntryType.selling)
        .fold<double>(0.0, (s, e) => s + e.amount);

    final weekNet = weekSelling - weekBuying;

    // Daily breakdown for the 7 days of the week (Mon to Sun)
    final List<Map<String, dynamic>> daysData = [];
    double peakVolume = 0.0;

    for (int i = 0; i < 7; i++) {
      final day = _selectedWeekStart.add(Duration(days: i));
      final dayList = weekEntries.where((e) => _isSameDay(e.date, day)).toList();
      final b = dayList
          .where((e) => e.type == CoconutEntryType.buying)
          .fold<double>(0.0, (s, e) => s + e.amount);
      final s = dayList
          .where((e) => e.type == CoconutEntryType.selling)
          .fold<double>(0.0, (s, e) => s + e.amount);

      final volume = b + s;
      if (volume > peakVolume) peakVolume = volume;

      daysData.add({
        'date': day,
        'dayName': DateFormat('E').format(day),
        'fullDate': DateFormat('dd MMM').format(day),
        'buying': b,
        'selling': s,
        'net': s - b,
        'count': dayList.length,
      });
    }

    return RefreshIndicator(
      onRefresh: _loadAllCoconutData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week Selector
            _buildWeekSelector(weekEnd),
            const SizedBox(height: 14),

            // Hero Weekly Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range_rounded, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat("dd MMM").format(_selectedWeekStart)} - ${DateFormat("dd MMM yyyy").format(weekEnd)}'
                            .toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🛒 Weekly Buying', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(
                                _currencyFormatter.format(weekBuying),
                                style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💰 Weekly Selling', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(
                                _currencyFormatter.format(weekSelling),
                                style: const TextStyle(color: Color(0xFF81C784), fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          weekNet >= 0 ? '✨ Weekly Net Profit:' : 'Weekly Net Outflow:',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _currencyFormatter.format(weekNet),
                          style: TextStyle(
                            color: weekNet >= 0 ? Colors.greenAccent : Colors.amberAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Visual Day-by-Day Bars
            const Text(
              'Weekly Activity Bars (Buying vs Selling)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.textDark),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: daysData.map((d) {
                  final b = d['buying'] as double;
                  final s = d['selling'] as double;
                  final total = b + s;
                  final double ratio = peakVolume > 0 ? (total / peakVolume).clamp(0.06, 1.0) : 0.06;
                  final isSelectedDay = _isSameDay(d['date'] as DateTime, _selectedDate);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = d['date'] as DateTime;
                        _tabController.animateTo(0);
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          total > 0 ? '₹${total.toInt()}' : '',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: total > 0 ? AppConstants.coconutBrown : Colors.transparent,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 24,
                          height: 100 * ratio,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: total == 0
                                ? Colors.grey.shade200
                                : (s > b ? const Color(0xFF2E7D32) : const Color(0xFFE65100)),
                          ),
                          child: total > 0 && b > 0 && s > 0
                              ? Column(
                                  children: [
                                    Expanded(
                                      flex: (s * 10).toInt(),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2E7D32),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: (b * 10).toInt(),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE65100),
                                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          d['dayName'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.w500,
                            color: isSelectedDay ? AppConstants.coconutBrown : Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          DateFormat('dd').format(d['date'] as DateTime),
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Daily List Breakdown
            const Text(
              'Day-by-Day Breakdown',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.textDark),
            ),
            const SizedBox(height: 10),
            ...daysData.map((d) {
              final dayDate = d['date'] as DateTime;
              final b = d['buying'] as double;
              final s = d['selling'] as double;
              final net = d['net'] as double;
              final count = d['count'] as int;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      _selectedDate = dayDate;
                      _tabController.animateTo(0);
                    });
                  },
                  leading: CircleAvatar(
                    backgroundColor: count > 0 ? AppConstants.coconutBrown.withValues(alpha: 0.15) : Colors.grey.shade100,
                    child: Text(
                      d['dayName'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: count > 0 ? AppConstants.coconutBrown : Colors.grey,
                      ),
                    ),
                  ),
                  title: Text(
                    DateFormat('EEEE, dd MMM').format(dayDate),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    'Buy: ${_currencyFormatter.format(b)} | Sell: ${_currencyFormatter.format(s)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currencyFormatter.format(net),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: net > 0 ? const Color(0xFF2E7D32) : (net < 0 ? Colors.red.shade700 : Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector(DateTime weekEnd) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF1565C0)),
            tooltip: 'Previous Week',
            onPressed: () {
              setState(() {
                _selectedWeekStart = _selectedWeekStart.subtract(const Duration(days: 7));
              });
            },
          ),
          Text(
            '${DateFormat("dd MMM").format(_selectedWeekStart)} - ${DateFormat("dd MMM yyyy").format(weekEnd)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppConstants.textDark,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFF1565C0)),
            tooltip: 'Next Week',
            onPressed: () {
              setState(() {
                _selectedWeekStart = _selectedWeekStart.add(const Duration(days: 7));
              });
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: MONTHLY ANALYZER
  // ==========================================
  Widget _buildMonthlyAnalyzerTab() {
    final monthEntries = _applyFilter(
      _allEntries.where((e) {
        return e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month;
      }).toList(),
    );

    final monthBuying = monthEntries
        .where((e) => e.type == CoconutEntryType.buying)
        .fold<double>(0.0, (s, e) => s + e.amount);

    final monthSelling = monthEntries
        .where((e) => e.type == CoconutEntryType.selling)
        .fold<double>(0.0, (s, e) => s + e.amount);

    final monthNet = monthSelling - monthBuying;

    // Group by day
    final Map<int, List<UnifiedCoconutEntry>> groupedByDay = {};
    for (var entry in monthEntries) {
      final day = entry.date.day;
      groupedByDay.putIfAbsent(day, () => []).add(entry);
    }

    final sortedDays = groupedByDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: _loadAllCoconutData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            _buildMonthSelector(),
            const SizedBox(height: 14),

            // Hero Month Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Colors.amberAccent, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('🛒 Total Buying', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(
                                _currencyFormatter.format(monthBuying),
                                style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('💰 Total Selling', style: TextStyle(color: Colors.white70, fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(
                                _currencyFormatter.format(monthSelling),
                                style: const TextStyle(color: Color(0xFF81C784), fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          monthNet >= 0 ? '✨ Monthly Net Profit:' : 'Monthly Net Outflow:',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _currencyFormatter.format(monthNet),
                          style: TextStyle(
                            color: monthNet >= 0 ? Colors.greenAccent : Colors.amberAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Active Days List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Days in ${DateFormat("MMM yyyy").format(_selectedMonth)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.textDark),
                ),
                Text(
                  '${sortedDays.length} days with activity',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (sortedDays.isEmpty)
              _buildMonthEmptyState()
            else
              ...sortedDays.map((day) {
                final dayList = groupedByDay[day]!;
                final b = dayList
                    .where((e) => e.type == CoconutEntryType.buying)
                    .fold<double>(0.0, (s, e) => s + e.amount);
                final s = dayList
                    .where((e) => e.type == CoconutEntryType.selling)
                    .fold<double>(0.0, (s, e) => s + e.amount);
                final net = s - b;
                final dateObj = DateTime(_selectedMonth.year, _selectedMonth.month, day);

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        _selectedDate = dateObj;
                        _tabController.animateTo(0);
                      });
                    },
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                      child: Text(
                        '$day',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                      ),
                    ),
                    title: Text(
                      DateFormat('EEEE, dd MMMM yyyy').format(dateObj),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Buy: ${_currencyFormatter.format(b)} | Sell: ${_currencyFormatter.format(s)} (${dayList.length} items)',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currencyFormatter.format(net),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: net > 0 ? const Color(0xFF2E7D32) : (net < 0 ? Colors.red.shade700 : Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Color(0xFF2E7D32)),
            tooltip: 'Previous Month',
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
              });
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppConstants.textDark,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Color(0xFF2E7D32)),
            tooltip: 'Next Month',
            onPressed: () {
              setState(() {
                _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMonthEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text('📅', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            'No Coconut Activity Recorded in ${DateFormat("MMMM yyyy").format(_selectedMonth)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.textDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Use the buttons above or record a new coconut transaction to populate your monthly business analyzer.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // UNIFIED CARD FOR ANY COCONUT ENTRY (BUY / SELL)
  // ==========================================
  Widget _buildUnifiedEntryCard(UnifiedCoconutEntry entry) {
    final isBuying = entry.type == CoconutEntryType.buying;
    final badgeColor = isBuying ? const Color(0xFFE65100) : const Color(0xFF2E7D32);
    final badgeText = isBuying ? 'BUYING / EXPENSE' : 'SELLING / REVENUE';
    final sign = isBuying ? '-' : '+';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: entry.themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(entry.iconEmoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 0.8),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          Text(
                            '$sign${_currencyFormatter.format(entry.amount)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isBuying ? const Color(0xFFD84315) : const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(entry.date),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                          if (entry.paymentMethod != null && entry.paymentMethod!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300, width: 0.8),
                              ),
                              child: Text(
                                entry.paymentMethod!,
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  entry.note!,
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
                ),
              ),
            ],
            const Divider(height: 16, thickness: 0.6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => ReceiptDialog.show(context, entry.asExpense),
                  icon: const Icon(Icons.receipt_long_rounded, size: 16, color: AppConstants.coconutBrown),
                  label: const Text(
                    'Receipt & WhatsApp',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.coconutBrown),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppConstants.coconutBrown),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Modal to add any type of Coconut Entry
  void _showAddOptionsModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Coconut Business Entry',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppConstants.textDark),
            ),
            const SizedBox(height: 6),
            Text(
              'Select what type of coconut transaction to record:',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Text('🌾', style: TextStyle(fontSize: 20)),
              ),
              title: const Text('Farmer Coconut Payment / Purchase', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Money paid or purchase made from coconut farmers'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FarmerListScreen()),
                );
                _loadAllCoconutData();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEFEBE9),
                child: Text('🛒', style: TextStyle(fontSize: 20)),
              ),
              title: const Text('Trader Coconut Collection / Sale', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Money received or sale made to coconut traders'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TraderListScreen()),
                );
                _loadAllCoconutData();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFBE9E7),
                child: Text('🌴', style: TextStyle(fontSize: 20)),
              ),
              title: const Text('Byproduct Earning (Thotti, Mattai, Paruppu)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Shell, husk, or raw coconut kernel sales'),
              onTap: () async {
                Navigator.pop(context);
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddResourceEarningScreen()),
                );
                if (res == true) _loadAllCoconutData();
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Text('🥥', style: TextStyle(fontSize: 20)),
              ),
              title: const Text('Direct Coconut Expense', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('General expense under Coconut category'),
              onTap: () async {
                Navigator.pop(context);
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddExpenseScreen(initialCategory: 'Coconut'),
                  ),
                );
                if (res == true) _loadAllCoconutData();
              },
            ),
          ],
        ),
      ),
    );
  }
}
