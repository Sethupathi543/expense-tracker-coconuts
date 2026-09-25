import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/trader.dart';
import '../../../services/coconut_business_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';

class AddTraderTransactionScreen extends StatefulWidget {
  final Trader trader;
  const AddTraderTransactionScreen({super.key, required this.trader});

  @override
  State<AddTraderTransactionScreen> createState() =>
      _AddTraderTransactionScreenState();
}

class _AddTraderTransactionScreenState
    extends State<AddTraderTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final CoconutBusinessService _service = CoconutBusinessService();

  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _paymentMethod;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _service.addTraderTransaction(
        traderId: widget.trader.id,
        amountReceived: double.parse(_amountCtrl.text.trim()),
        date: _selectedDate,
        paymentMethod: _paymentMethod,
        note: _noteCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt recorded!'),
                backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trader = widget.trader;
    final entered = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final newRemaining = trader.remainingAmount - entered;

    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        title: Text('Receipt from ${trader.name}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppConstants.coconutBrown,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Pending amount chip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown[300]!),
              ),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pending Collection from ${trader.name}',
                    style: TextStyle(color: Colors.brown[800], fontSize: 13)),
                Text('₹${trader.remainingAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                        color: Colors.brown[900],
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: Validators.positiveNumber('Amount'),
              decoration: InputDecoration(
                labelText: 'Amount Received (₹) *',
                prefixText: '₹ ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppConstants.coconutBrown, width: 2),
                ),
              ),
            ),
            // Live Remaining Balance Calculation Card
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: entered > 0
                      ? (newRemaining <= 0.01 ? Colors.green : Colors.orange.shade300)
                      : Colors.grey.shade300,
                  width: entered > 0 ? 1.5 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Current Due:', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      Text('₹${trader.remainingAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Receiving Now:', style: TextStyle(fontSize: 12, color: Colors.green)),
                      Text('(-) ₹${entered.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const Divider(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('New Remaining Balance:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(
                        '₹${newRemaining.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: newRemaining <= 0.01 ? Colors.green.shade700 : Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  if (entered > 0) ...[
                    const SizedBox(height: 8),
                    if (newRemaining <= 0.01)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                newRemaining < 0
                                    ? 'Settled + ₹${(-newRemaining).toStringAsFixed(2)} advance balance'
                                    : 'Trader account will be fully cleared & settled!',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        '⏳ Remaining ₹${newRemaining.toStringAsFixed(2)} will stay pending for future collection.',
                        style: TextStyle(fontSize: 11, color: Colors.orange.shade900),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                      const Icon(Icons.calendar_today, size: 18),
                    ]),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _paymentMethod,
              hint: const Text('Payment Method'),
              decoration: InputDecoration(
                labelText: 'Payment Method',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              items: AppConstants.paymentMethods
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _paymentMethod = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Note',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.coconutBrown,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Record Receipt',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
