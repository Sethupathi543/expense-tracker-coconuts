import 'package:flutter/material.dart';
import '../../../models/trader.dart';
import '../../../services/coconut_business_service.dart';
import '../../../utils/constants.dart';
import 'add_trader_transaction_screen.dart';

class TraderDetailScreen extends StatefulWidget {
  final Trader trader;
  const TraderDetailScreen({super.key, required this.trader});

  @override
  State<TraderDetailScreen> createState() => _TraderDetailScreenState();
}

class _TraderDetailScreenState extends State<TraderDetailScreen> {
  final CoconutBusinessService _service = CoconutBusinessService();
  Trader? _trader;
  List<TraderTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final trader = await _service.getTraderById(widget.trader.id);
      final txns = await _service.getTraderTransactions(widget.trader.id);
      if (mounted) {
        setState(() {
          _trader = trader;
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

  Future<void> _deleteTransaction(TraderTransaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Transaction'),
        content:
            Text('Delete received amount of ₹${tx.amountReceived.toStringAsFixed(2)}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
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
        await _service.deleteTraderTransaction(widget.trader.id, tx.id);
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
    final trader = _trader ?? widget.trader;
    final pct = trader.totalSaleAmount > 0
        ? (trader.totalReceived / trader.totalSaleAmount).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        title: Text(trader.name,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppConstants.coconutBrown,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AddTraderTransactionScreen(trader: trader)));
          _load();
        },
        backgroundColor: AppConstants.coconutBrown,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Receipt', style: TextStyle(color: Colors.white)),
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
                                backgroundColor: AppConstants.coconutBrown,
                                child: Text(trader.name[0].toUpperCase(),
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
                                    Text(trader.name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    if (trader.phone != null &&
                                        trader.phone!.isNotEmpty)
                                      Text('📞 ${trader.phone}',
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                    if (trader.location != null &&
                                        trader.location!.isNotEmpty)
                                      Text('📍 ${trader.location}',
                                          style: TextStyle(
                                              color: Colors.grey[600])),
                                  ])),
                            ]),
                            if (trader.note != null &&
                                trader.note!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('📝 ${trader.note}',
                                  style: TextStyle(
                                      color: Colors.grey[700], fontSize: 13)),
                            ],
                            const SizedBox(height: 16),
                            Row(children: [
                              Expanded(
                                  child: _amountBox('Total Sale',
                                      trader.totalSaleAmount, Colors.blue)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _amountBox('Received',
                                      trader.totalReceived, Colors.green)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _amountBox('Pending',
                                      trader.remainingAmount, Colors.orange)),
                            ]),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 10,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    pct >= 1.0
                                        ? Colors.green
                                        : AppConstants.coconutBrown),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${(pct * 100).toStringAsFixed(1)}% received',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12)),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Receipt History (${_transactions.length})',
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
                          child: Text('No receipts yet. Tap + to add one.',
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

  Widget _buildTransactionCard(TraderTransaction tx) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.brown[100],
          child: Icon(Icons.account_balance_wallet_rounded,
              color: AppConstants.coconutBrown),
        ),
        title: Text('₹${tx.amountReceived.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(tx.formattedDate, style: TextStyle(color: Colors.grey[600])),
          if (tx.paymentMethod != null && tx.paymentMethod!.isNotEmpty)
            Text(tx.paymentMethod!,
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          if (tx.note != null && tx.note!.isNotEmpty)
            Text(tx.note!,
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ]),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deleteTransaction(tx),
        ),
      ),
    );
  }
}
