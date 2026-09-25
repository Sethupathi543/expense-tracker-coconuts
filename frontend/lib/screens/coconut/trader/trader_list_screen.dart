import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/trader.dart';
import '../../../services/coconut_business_service.dart';
import '../../../utils/constants.dart';
import 'add_trader_screen.dart';
import 'add_trader_transaction_screen.dart';
import 'trader_detail_screen.dart';

class TraderListScreen extends StatefulWidget {
  const TraderListScreen({super.key});

  @override
  State<TraderListScreen> createState() => _TraderListScreenState();
}

class _TraderListScreenState extends State<TraderListScreen>
    with SingleTickerProviderStateMixin {
  final CoconutBusinessService _service = CoconutBusinessService();
  late TabController _tabController;

  List<Trader> _traders = [];
  List<TraderTransaction> _allTransactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final traders = await _service.getTraders();
      final txns = await _service.getAllTraderTransactions();
      if (mounted) {
        setState(() {
          _traders = traders;
          _allTransactions = txns;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteTrader(Trader trader) async {
    final isSettled = trader.remainingAmount <= 0.01;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isSettled ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: isSettled ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(isSettled ? 'Settle & Delete Trader' : 'Delete Trader'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSettled
                  ? 'All payments from "${trader.name}" are received (₹${trader.totalReceived.toStringAsFixed(2)} collected).'
                  : 'Warning: "${trader.name}" still owes ₹${trader.remainingAmount.toStringAsFixed(2)}.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Removing this trader hides them from the active list. All payment history is safely stored in the backend and will be restored whenever you re-add "${trader.name}".',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isSettled ? AppConstants.coconutBrown : Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              isSettled ? 'Settle & Archive' : 'Delete',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteTrader(trader.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '"${trader.name}" archived. Data is preserved and will be restored if re-added.',
              ),
              backgroundColor: AppConstants.coconutBrown,
            ),
          );
        }
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Traders',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppConstants.coconutBrown,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.storefront_rounded), text: 'Traders'),
            Tab(icon: Icon(Icons.receipt_long_rounded), text: 'Payments Received'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTraderScreen()),
          );
          _load();
        },
        backgroundColor: AppConstants.coconutBrown,
        icon: const Icon(Icons.storefront_rounded, color: Colors.white),
        label: const Text('Add Trader', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTradersTab(),
                _buildPaymentsReceivedTab(),
              ],
            ),
    );
  }

  Widget _buildTradersTab() {
    if (_traders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront_rounded, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No active traders',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a trader',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _traders.length,
      itemBuilder: (_, i) => _buildTraderCard(_traders[i]),
    );
  }

  Widget _buildTraderCard(Trader trader) {
    final pct = trader.totalSaleAmount > 0
        ? (trader.totalReceived / trader.totalSaleAmount).clamp(0.0, 1.0)
        : 0.0;
    final isSettled = trader.remainingAmount <= 0.01;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TraderDetailScreen(trader: trader),
            ),
          );
          _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppConstants.coconutBrown,
                    child: Text(
                      trader.name.isNotEmpty ? trader.name[0].toUpperCase() : 'T',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                trader.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isSettled) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Settled',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (trader.location != null &&
                            trader.location!.isNotEmpty)
                          Text(
                            trader.location!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isSettled ? Icons.archive_outlined : Icons.delete_outline,
                      color: isSettled ? Colors.green.shade700 : Colors.red,
                    ),
                    tooltip: isSettled ? 'Settle & Archive' : 'Delete Trader',
                    onPressed: () => _deleteTrader(trader),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _amountChip(
                      'Total Sales',
                      trader.totalSaleAmount,
                      Colors.blue[700]!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _amountChip(
                      'Received',
                      trader.totalReceived,
                      Colors.green[700]!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _amountChip(
                      'Pending',
                      trader.remainingAmount,
                      Colors.orange[800]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    pct >= 1.0 ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(pct * 100).toStringAsFixed(0)}% collected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: pct >= 1.0 ? Colors.green.shade700 : Colors.orange.shade800,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddTraderTransactionScreen(trader: trader)),
                      );
                      _load();
                    },
                    icon: const Icon(Icons.add, size: 15),
                    label: const Text('+ Receive Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.coconutBrown,
                      side: const BorderSide(color: AppConstants.coconutBrown),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _amountChip(String label, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== PAYMENTS RECEIVED TAB =====================

  Widget _buildPaymentsReceivedTab() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final totalReceived =
        _traders.fold<double>(0.0, (sum, t) => sum + t.totalReceived);
    final totalRemaining =
        _traders.fold<double>(0.0, (sum, t) => sum + t.remainingAmount);
    final totalSales =
        _traders.fold<double>(0.0, (sum, t) => sum + t.totalSaleAmount);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big Metric Card: How Much Received from Traders
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5D4037), Color(0xFF3E2723)],
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
                const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded,
                        color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'TOTAL PAYMENTS RECEIVED',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormatter.format(totalReceived),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Sales',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          currencyFormatter.format(totalSales),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Pending Collection',
                          style: TextStyle(color: Colors.amberAccent, fontSize: 11),
                        ),
                        Text(
                          currencyFormatter.format(totalRemaining),
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Received Per Trader Summary
          const Text(
            'Received Per Trader',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppConstants.textDark,
            ),
          ),
          const SizedBox(height: 12),

          if (_traders.isEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No trader data recorded yet.'),
              ),
            )
          else
            ..._traders.map((trader) {
              final isSettled = trader.remainingAmount <= 0.01;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSettled
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isSettled
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      child: Icon(
                        isSettled
                            ? Icons.check_circle_rounded
                            : Icons.hourglass_bottom_rounded,
                        size: 20,
                        color: isSettled
                            ? Colors.green.shade700
                            : Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trader.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            isSettled
                                ? 'Fully Settled'
                                : 'Pending: ₹${trader.remainingAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSettled
                                  ? Colors.green.shade700
                                  : Colors.orange.shade800,
                              fontWeight: isSettled
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${trader.totalReceived.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                        Text(
                          'of ₹${trader.totalSaleAmount.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),

          // Payment Receipts Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Payment Receipts',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textDark,
                ),
              ),
              Text(
                '${_allTransactions.length} total',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_allTransactions.isEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('No payment receipts recorded yet.'),
                ),
              ),
            )
          else
            ..._allTransactions.map((tx) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.brown.shade100,
                    child: Icon(Icons.receipt_rounded,
                        color: Colors.brown.shade800, size: 20),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tx.traderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '₹${tx.amountReceived.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tx.formattedDate,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      if (tx.paymentMethod != null &&
                          tx.paymentMethod!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tx.paymentMethod!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
