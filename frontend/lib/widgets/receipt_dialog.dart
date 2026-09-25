import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../utils/constants.dart';
import '../utils/print_helper.dart';
import '../utils/url_helper.dart';

class ReceiptDialog extends StatelessWidget {
  final Expense expense;

  const ReceiptDialog({super.key, required this.expense});

  static Future<void> show(BuildContext context, Expense expense) {
    return showDialog(
      context: context,
      builder: (_) => ReceiptDialog(expense: expense),
    );
  }

  String _generateReceiptText() {
    final dateFormatter = DateFormat('dd MMM yyyy');
    return '''
🧾 *COCONUT EXPENSE TRACKER - RECEIPT*
━━━━━━━━━━━━━━━━━━━━
📌 *Receipt No:* #EXP-${expense.id ?? 'N/A'}
📅 *Date:* ${dateFormatter.format(expense.date)}
📂 *Category:* ${expense.category} ${AppConstants.getCategoryEmoji(expense.category)}
💰 *Amount:* ₹${expense.amount.toStringAsFixed(2)}
💳 *Payment Mode:* ${expense.paymentMethod}
${expense.note.isNotEmpty ? "📝 *Note:* ${expense.note}\n" : ""}━━━━━━━━━━━━━━━━━━━━
🌴 _Tracked with Coconut Expense Tracker_
''';
  }

  void _shareOnWhatsApp(BuildContext context) {
    final text = _generateReceiptText();
    Clipboard.setData(ClipboardData(text: text));
    final whatsappUrl = 'https://api.whatsapp.com/send?text=${Uri.encodeComponent(text)}';
    launchExternalUrl(whatsappUrl);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Opening WhatsApp... Receipt text also copied to clipboard!',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF25D366),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _shareReceipt(BuildContext context) {
    final text = _generateReceiptText();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Receipt copied to clipboard! Paste it to share with friends on WhatsApp / SMS.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppConstants.primaryGreen,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd MMMM yyyy');
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: AppConstants.currency,
      decimalDigits: 2,
    );

    final catColor = AppConstants.getCategoryColor(expense.category);
    final catEmoji = AppConstants.getCategoryEmoji(expense.category);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Green Banner
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              decoration: const BoxDecoration(
                color: AppConstants.primaryGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXPENSE RECEIPT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          'Coconut Expense Tracker',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Receipt Paper Content
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  // Receipt No & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Receipt #EXP-${expense.id ?? "00"}',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                      ),
                      Text(
                        dateFormatter.format(expense.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Amount Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: catColor.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'TOTAL AMOUNT PAID',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: catColor, letterSpacing: 1),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currencyFormatter.format(expense.amount),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Details Breakdown
                  _buildDetailRow('Category', '${expense.category} $catEmoji', badgeColor: catColor),
                  const Divider(height: 20, thickness: 0.8),
                  _buildDetailRow('Payment Mode', expense.paymentMethod),
                  const Divider(height: 20, thickness: 0.8),
                  _buildDetailRow('Date Paid', dateFormatter.format(expense.date)),
                  if (expense.note.isNotEmpty) ...[
                    const Divider(height: 20, thickness: 0.8),
                    _buildDetailRow('Note / Remarks', expense.note),
                  ],
                  const SizedBox(height: 22),

                  // Primary Action: Share via WhatsApp
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _shareOnWhatsApp(context),
                      icon: const Icon(Icons.chat_rounded, size: 20, color: Colors.white),
                      label: const Text(
                        'Share on WhatsApp',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Secondary Actions: Print and Copy Receipt
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            triggerPrint();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Printing receipt...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.print_outlined, size: 18),
                          label: const Text('Print'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppConstants.textDark,
                            side: BorderSide(color: Colors.grey.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _shareReceipt(context),
                          icon: const Icon(Icons.copy_rounded, size: 18, color: AppConstants.primaryGreen),
                          label: const Text('Copy / SMS', style: TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryGreen)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppConstants.primaryGreen),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? badgeColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: badgeColor != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                )
              : Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textDark,
                  ),
                ),
        ),
      ],
    );
  }
}
