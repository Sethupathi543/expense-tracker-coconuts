import 'package:flutter/material.dart';
import '../../../services/coconut_business_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/validators.dart';

class AddTraderScreen extends StatefulWidget {
  const AddTraderScreen({super.key});

  @override
  State<AddTraderScreen> createState() => _AddTraderScreenState();
}

class _AddTraderScreenState extends State<AddTraderScreen> {
  final _formKey = GlobalKey<FormState>();
  final CoconutBusinessService _service = CoconutBusinessService();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _service.addTrader(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        totalSaleAmount: double.parse(_amountCtrl.text.trim()),
        note: _noteCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trader added successfully!'),
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
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        title: const Text('Add Trader',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppConstants.coconutBrown,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _buildField('Trader Name *', _nameCtrl,
                validator: Validators.required('Name')),
            const SizedBox(height: 12),
            _buildField('Phone Number', _phoneCtrl,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _buildField('Location / Village', _locationCtrl),
            const SizedBox(height: 12),
            _buildField('Total Sale Amount (₹) *', _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator:
                    Validators.positiveNumber('Total Sale Amount')),
            const SizedBox(height: 12),
            _buildField('Note', _noteCtrl, maxLines: 3),
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
                    : const Text('Add Trader',
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

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType? keyboardType,
      String? Function(String?)? validator,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: AppConstants.coconutBrown, width: 2),
        ),
      ),
    );
  }
}
