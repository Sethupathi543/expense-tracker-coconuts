import 'package:flutter/material.dart';
import '../../../models/farmer.dart';
import '../../../services/coconut_business_service.dart';
import '../../../utils/constants.dart';
import 'add_farmer_transaction_screen.dart';

class FarmerDetailScreen extends StatefulWidget {
  final Farmer farmer;
  const FarmerDetailScreen({super.key, required this.farmer});

  @override
  State<FarmerDetailScreen> createState() => _FarmerDetailScreenState();
}

class _FarmerDetailScreenState extends State<FarmerDetailScreen> {
  final CoconutBusinessService _service = CoconutBusinessService();
  Farmer? _farmer;
  List<FarmerTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final farmer = await _service.getFarmerById(widget.farmer.id);
      final txns = await _service.getFarmerTransactions(widget.farmer.id);
      if (mounted) {
        setState(() {
          _farmer = farmer;
          _transactions = txns;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteTransaction(FarmerTransaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete payment of ₹${tx.amountGiven.toStringAsFixed(2)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _service.deleteFarmerTransaction(widget.farmer.id, tx.id);
        _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmer = _farmer ?? widget.farmer;
    final pct = farmer.totalPurchaseAmount > 0
        ? (farmer.totalPaid / farmer.totalPurchaseAmount).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        title: Text(farmer.name,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF388E3C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddFarmerTransactionScreen(farmer: farmer)));
          _load();
        },
        backgroundColor: const Color(0xFF388E3C),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Payment', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                children: [
                  // Info card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFF388E3C),
                                child: Text(farmer.name[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(farmer.name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    if (farmer.phone != null &&
                                        farmer.phone!.isNotEmpty)
                                      Text('📞 ${farmer.phone}',
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                    if (farmer.location != null &&
                                        farmer.location!.isNotEmpty)
                                      Text('📍 ${farmer.location}',
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                  ])),
                            ]),
                            if (farmer.note != null &&
                                farmer.note!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('📝 ${farmer.note}',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13)),
                            ],
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(
                                  child: _amountBox('Total Purchase',
                                      farmer.totalPurchaseAmount, Colors.blue)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _amountBox(
                                      'Paid', farmer.totalPaid, Colors.green)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _amountBox('Remaining',
                                      farmer.remainingAmount, Colors.orange)),
                            ]),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 10,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    pct >= 1.0 ? Colors.green : Colors.orange),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                                '${(pct * 100).toStringAsFixed(1)}% paid',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Payment History (${_transactions.length})',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_transactions.isEmpty)
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text('No payments yet. Tap + to add one.',
                              style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                    )
                  else
                    ..._transactions
                        .map((tx) => _buildTransactionCard(tx)),
                ],
              ),
            ),
    );
  }

  Widget _amountBox(String label, double amount, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: color[700]),
            textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text('₹${amount.toStringAsFixed(0)}',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color[800])),
      ]),
    );
  }

  Widget _buildTransactionCard(FarmerTransaction tx) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.payments_rounded, color: Colors.green[700]),
        ),
        title: Text('₹${tx.amountGiven.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.formattedDate, style: TextStyle(color: Colors.grey[600])),
          if (tx.paymentMethod != null && tx.paymentMethod!.isNotEmpty)
            Text(tx.paymentMethod!, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          if (tx.note != null && tx.note!.isNotEmpty)
            Text(tx.note!, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ]),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deleteTransaction(tx),
        ),
      ),
    );
  }
}
