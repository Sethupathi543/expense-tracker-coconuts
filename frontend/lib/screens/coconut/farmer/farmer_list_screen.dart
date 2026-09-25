import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/farmer.dart';
import '../../../services/coconut_business_service.dart';
import '../../../utils/constants.dart';
import 'add_farmer_screen.dart';
import 'farmer_detail_screen.dart';

class FarmerListScreen extends StatefulWidget {
  const FarmerListScreen({super.key});

  @override
  State<FarmerListScreen> createState() => _FarmerListScreenState();
}

class _FarmerListScreenState extends State<FarmerListScreen>
    with SingleTickerProviderStateMixin {
  final CoconutBusinessService _service = CoconutBusinessService();
  late TabController _tabController;

  List<Farmer> _farmers = [];
  List<FarmerTransaction> _allTransactions = [];
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
      final farmers = await _service.getFarmers();
      final txns = await _service.getAllFarmerTransactions();
      if (mounted) {
        setState(() {
          _farmers = farmers;
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

  Future<void> _deleteFarmer(Farmer farmer) async {
    final isSettled = farmer.remainingAmount <= 0.01;
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
            Text(isSettled ? 'Settle & Delete Farmer' : 'Delete Farmer'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSettled
                  ? 'All payments for "${farmer.name}" are complete (₹${farmer.totalPaid.toStringAsFixed(2)} paid).'
                  : 'Warning: "${farmer.name}" has ₹${farmer.remainingAmount.toStringAsFixed(2)} remaining to be paid.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              'Removing this farmer hides them from the active list. All payment history is safely stored in the backend and will be restored whenever you re-add "${farmer.name}".',
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
              backgroundColor: isSettled ? const Color(0xFF388E3C) : Colors.red,
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
        await _service.deleteFarmer(farmer.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '"${farmer.name}" archived. Data is preserved and will be restored if re-added.',
              ),
              backgroundColor: const Color(0xFF388E3C),
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
          'Farmers',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF388E3C),
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
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Farmers'),
            Tab(icon: Icon(Icons.payments_rounded), text: 'Payments Given'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFarmerScreen()),
          );
          _load();
        },
        backgroundColor: const Color(0xFF388E3C),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: const Text('Add Farmer', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFarmersTab(),
                _buildPaymentsGivenTab(),
              ],
            ),
    );
  }

  Widget _buildFarmersTab() {
    if (_farmers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture_rounded, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No active farmers',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add a farmer',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _farmers.length,
      itemBuilder: (_, i) => _buildFarmerCard(_farmers[i]),
    );
  }

  Widget _buildFarmerCard(Farmer farmer) {
    final pct = farmer.totalPurchaseAmount > 0
        ? (farmer.totalPaid / farmer.totalPurchaseAmount).clamp(0.0, 1.0)
        : 0.0;
    final isSettled = farmer.remainingAmount <= 0.01;

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
              builder: (_) => FarmerDetailScreen(farmer: farmer),
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
                    backgroundColor: const Color(0xFF388E3C),
                    child: Text(
                      farmer.name.isNotEmpty ? farmer.name[0].toUpperCase() : 'F',
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
                                farmer.name,
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
                        if (farmer.location != null &&
                            farmer.location!.isNotEmpty)
                          Text(
                            farmer.location!,
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
                    tooltip: isSettled ? 'Settle & Archive' : 'Delete Farmer',
                    onPressed: () => _deleteFarmer(farmer),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _amountChip(
                      'Total Purchase',
                      farmer.totalPurchaseAmount,
                      Colors.blue[700]!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _amountChip(
                      'Given (Paid)',
                      farmer.totalPaid,
                      Colors.green[700]!,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _amountChip(
                      'Remaining',
                      farmer.remainingAmount,
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

  // ===================== PAYMENTS GIVEN TAB =====================

  Widget _buildPaymentsGivenTab() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final totalGiven = _farmers.fold<double>(0.0, (sum, f) => sum + f.totalPaid);
    final totalRemaining =
        _farmers.fold<double>(0.0, (sum, f) => sum + f.remainingAmount);
    final totalPurchases =
        _farmers.fold<double>(0.0, (sum, f) => sum + f.totalPurchaseAmount);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Big Metric Card: How Much Given to Farmers
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                const Row(
                  children: [
                    Icon(Icons.payments_rounded, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'TOTAL PAYMENTS GIVEN',
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
                  currencyFormatter.format(totalGiven),
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
                          'Total Purchases',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          currencyFormatter.format(totalPurchases),
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
                          'Remaining to Pay',
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

          // Given Per Farmer Summary
          const Text(
            'Given Per Farmer',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppConstants.textDark,
            ),
          ),
          const SizedBox(height: 12),

          if (_farmers.isEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No farmer data recorded yet.'),
              ),
            )
          else
            ..._farmers.map((farmer) {
              final isSettled = farmer.remainingAmount <= 0.01;
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
                            farmer.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            isSettled
                                ? 'Fully Settled'
                                : 'Pending: ₹${farmer.remainingAmount.toStringAsFixed(0)}',
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
                          '₹${farmer.totalPaid.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        Text(
                          'of ₹${farmer.totalPurchaseAmount.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),

          // Payment Transactions Feed
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Payment Transactions',
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
                  child: Text('No payment transactions recorded yet.'),
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
                    backgroundColor: Colors.green.shade100,
                    child: Icon(Icons.payment_rounded,
                        color: Colors.green.shade800, size: 20),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tx.farmerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '₹${tx.amountGiven.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF2E7D32),
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
