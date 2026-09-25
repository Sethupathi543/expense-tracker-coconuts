import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/coconut_business_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class AddResourceEarningScreen extends StatefulWidget {
  final String? initialResourceType;

  const AddResourceEarningScreen({super.key, this.initialResourceType});

  @override
  State<AddResourceEarningScreen> createState() => _AddResourceEarningScreenState();
}

class _AddResourceEarningScreenState extends State<AddResourceEarningScreen> {
  final _formKey = GlobalKey<FormState>();
  final CoconutBusinessService _service = CoconutBusinessService();

  late String _resourceType; // 'Thotti' or 'Mattai'
  final _quantityCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _buyerCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _selectedUnit = 'Kg';
  final List<String> _units = ['Kg', 'Tonnes', 'Bags', 'Loads / Trucks', 'Pieces'];

  String _selectedPaymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _resourceType = widget.initialResourceType ?? 'Thotti';
    _quantityCtrl.addListener(_recalcTotal);
    _rateCtrl.addListener(_recalcTotal);
  }

  void _recalcTotal() {
    final qty = double.tryParse(_quantityCtrl.text.trim());
    final rate = double.tryParse(_rateCtrl.text.trim());
    if (qty != null && rate != null && qty > 0 && rate > 0) {
      final total = qty * rate;
      _totalCtrl.text = total.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _rateCtrl.dispose();
    _totalCtrl.dispose();
    _buyerCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final total = double.parse(_totalCtrl.text.trim());
      final qty = double.tryParse(_quantityCtrl.text.trim());
      final rate = double.tryParse(_rateCtrl.text.trim());

      await _service.addResourceEarning(
        resourceType: _resourceType,
        quantity: qty,
        unit: _selectedUnit,
        ratePerUnit: rate,
        totalAmount: total,
        buyerName: _buyerCtrl.text.trim().isEmpty ? null : _buyerCtrl.text.trim(),
        date: _selectedDate,
        paymentMethod: _selectedPaymentMethod,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Earning of ₹${total.toStringAsFixed(2)} from $_resourceType recorded!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Color _getThemeColor() {
    switch (_resourceType.toLowerCase()) {
      case 'thotti':
        return const Color(0xFF6D4C41);
      case 'mattai':
        return const Color(0xFFD84315);
      case 'paruppu':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFF5D4037);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor();

    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Record Earning - $_resourceType',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Resource Type Switcher Card with images/illustrations
              const Text(
                'Select Resource Type',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppConstants.textDark),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    SizedBox(
                      width: 175,
                      child: _buildResourceTypeCard(
                        title: 'Thotti',
                        subtitle: 'Endocarp (Shell)',
                        emoji: '🥥',
                        badge: 'Hard Shell',
                        selected: _resourceType == 'Thotti',
                        color: const Color(0xFF6D4C41),
                        onTap: () => setState(() => _resourceType = 'Thotti'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 175,
                      child: _buildResourceTypeCard(
                        title: 'Mattai',
                        subtitle: 'Epicarp (Husk)',
                        emoji: '🌴',
                        badge: 'Outer Husk',
                        selected: _resourceType == 'Mattai',
                        color: const Color(0xFFD84315),
                        onTap: () => setState(() => _resourceType = 'Mattai'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 175,
                      child: _buildResourceTypeCard(
                        title: 'Paruppu',
                        subtitle: 'Raw Coconut Kernel',
                        emoji: '🥥',
                        badge: 'Copra Kernel',
                        selected: _resourceType == 'Paruppu',
                        color: const Color(0xFF2E7D32),
                        onTap: () => setState(() => _resourceType = 'Paruppu'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Buyer Name
              TextFormField(
                controller: _buyerCtrl,
                decoration: InputDecoration(
                  labelText: 'Buyer / Factory / Customer Name',
                  hintText: 'e.g. Activated Carbon Unit / Coir Mill',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Quantity & Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'e.g. 500',
                        prefixIcon: const Icon(Icons.scale_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnit = val);
                      },
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Rate per Unit
              TextFormField(
                controller: _rateCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Rate per $_selectedUnit (₹)',
                  prefixText: '₹ ',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Total Amount
              TextFormField(
                controller: _totalCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.positiveNumber('Total Amount'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
                decoration: InputDecoration(
                  labelText: 'Total Earning Amount (₹) *',
                  prefixText: '₹ ',
                  prefixIcon: Icon(Icons.payments_outlined, color: themeColor),
                  filled: true,
                  fillColor: Colors.white,
                  helperText: 'Auto-calculated if Quantity and Rate are provided',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Date Picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 20, color: themeColor),
                          const SizedBox(width: 10),
                          Text(
                            DateFormat('dd MMMM yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Text('Change', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Payment Method
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                items: AppConstants.paymentMethods
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedPaymentMethod = val);
                },
                decoration: InputDecoration(
                  labelText: 'Payment Method Received',
                  prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              // Notes
              TextFormField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes / Vehicle No / Details',
                  hintText: 'e.g. Sold 2 tractor loads of shell to carbon unit',
                  prefixIcon: const Icon(Icons.notes),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: Text(
                    _saving ? 'Saving...' : 'Record Earning',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceTypeCard({
    required String title,
    required String subtitle,
    required String emoji,
    required String badge,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: color, size: 18)
                else
                  const SizedBox(width: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: selected ? color : AppConstants.textDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
