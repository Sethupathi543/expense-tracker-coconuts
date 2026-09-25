import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/resource_earning.dart';
import '../../services/coconut_business_service.dart';
import '../../utils/constants.dart';
import 'add_resource_earning_screen.dart';

class ResourceEarningsScreen extends StatefulWidget {
  const ResourceEarningsScreen({super.key});

  @override
  State<ResourceEarningsScreen> createState() => _ResourceEarningsScreenState();
}

class _ResourceEarningsScreenState extends State<ResourceEarningsScreen>
    with SingleTickerProviderStateMixin {
  final CoconutBusinessService _service = CoconutBusinessService();

  List<ResourceEarning> _earnings = [];
  ResourceEarningSummary? _summary;
  bool _loading = true;
  String _selectedFilter = 'All'; // 'All', 'Thotti', 'Mattai'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final summary = await _service.getResourceEarningsSummary();
      final earnings = await _service.getResourceEarnings(
        resourceType: _selectedFilter == 'All' ? null : _selectedFilter,
      );
      if (mounted) {
        setState(() {
          _summary = summary;
          _earnings = earnings;
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

  Future<void> _deleteEarning(ResourceEarning earning) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Resource Earning'),
        content: Text(
          'Delete sale of ${earning.resourceType} for ₹${earning.totalAmount.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
        await _service.deleteResourceEarning(earning.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Earning entry deleted'),
              backgroundColor: Colors.brown,
            ),
          );
        }
        _loadData();
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
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Byproduct Earnings (Thotti, Mattai & Paruppu)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF5D4037),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Record Earning', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddResourceEarningScreen(
                initialResourceType: _selectedFilter == 'All' ? 'Thotti' : _selectedFilter,
              ),
            ),
          );
          if (res == true) _loadData();
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Summary Card
              _buildHeroSummaryCard(currencyFormatter),
              const SizedBox(height: 16),

              // Educational Resource Showcase Cards (Thotti, Mattai & Paruppu)
              _buildResourceCards(currencyFormatter),
              const SizedBox(height: 18),

              // Filter Tabs (Horizontally scrollable for mobile portrait compatibility)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('All Byproducts', 'All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('🥥 Thotti (Endocarp)', 'Thotti'),
                    const SizedBox(width: 8),
                    _buildFilterChip('🌴 Mattai (Epicarp)', 'Mattai'),
                    const SizedBox(width: 8),
                    _buildFilterChip('⚪ Paruppu (Raw Coconut)', 'Paruppu'),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Earnings List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_earnings.length} ${_earnings.length == 1 ? "Sale Entry" : "Sales Entries"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppConstants.textDark),
                  ),
                  Text(
                    'Total: ${currencyFormatter.format(_earnings.fold(0.0, (s, e) => s + e.totalAmount))}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF5D4037)),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Earnings list or empty state
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: Color(0xFF5D4037)),
                  ),
                )
              else if (_earnings.isEmpty)
                _buildEmptyState()
              else
                ..._earnings.map((earning) => _buildEarningCard(earning)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSummaryCard(NumberFormat formatter) {
    final total = _summary?.totalEarnings ?? 0.0;
    final thotti = _summary?.thottiEarnings ?? 0.0;
    final mattai = _summary?.mattaiEarnings ?? 0.0;
    final paruppu = _summary?.paruppuEarnings ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4E342E), Color(0xFF3E2723)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.35),
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
              Icon(Icons.monetization_on_outlined, color: Colors.amber, size: 22),
              SizedBox(width: 8),
              Text(
                'TOTAL BYPRODUCTS REVENUE',
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
            formatter.format(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🥥 Thotti',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatter.format(thotti),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 26, width: 1, color: Colors.white24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🌴 Mattai',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatter.format(mattai),
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 26, width: 1, color: Colors.white24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚪ Paruppu',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formatter.format(paruppu),
                        style: const TextStyle(
                          color: Color(0xFF81C784),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCards(NumberFormat formatter) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Thotti Card
          SizedBox(
            width: 210,
            child: _buildShowcaseCard(
              emoji: '🥥',
              badge: 'Endocarp',
              badgeColor: const Color(0xFF6D4C41),
              title: 'Thotti (Shell)',
              subtitle: 'Hard inner shell sold for activated carbon & charcoal.',
            ),
          ),
          const SizedBox(width: 10),

          // Mattai Card
          SizedBox(
            width: 210,
            child: _buildShowcaseCard(
              emoji: '🌴',
              badge: 'Epicarp',
              badgeColor: const Color(0xFFD84315),
              title: 'Mattai (Husk)',
              subtitle: 'Fibrous outer husk sold to coir mills for yarn & pith.',
            ),
          ),
          const SizedBox(width: 10),

          // Paruppu Card
          SizedBox(
            width: 210,
            child: _buildShowcaseCard(
              emoji: '🥥',
              badge: 'Raw Kernel',
              badgeColor: const Color(0xFF2E7D32),
              title: 'Paruppu (Raw)',
              subtitle: 'Fresh raw coconut kernel sold for oil extraction & food.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseCard({
    required String emoji,
    required String badge,
    required Color badgeColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: badgeColor),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF5D4037),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppConstants.textDark,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.white,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedFilter = value);
          _loadData();
        }
      },
    );
  }

  Widget _buildEarningCard(ResourceEarning earning) {
    final type = earning.resourceType.toLowerCase();
    final Color cardColor;
    final String emoji;
    final String subDesc;

    if (type == 'thotti') {
      cardColor = const Color(0xFF6D4C41);
      emoji = '🥥';
      subDesc = 'Endocarp / Shell';
    } else if (type == 'mattai') {
      cardColor = const Color(0xFFD84315);
      emoji = '🌴';
      subDesc = 'Epicarp / Husk';
    } else {
      cardColor = const Color(0xFF2E7D32);
      emoji = '🥥';
      subDesc = 'Raw Coconut / Kernel';
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${earning.resourceType} ($subDesc)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: cardColor,
                            ),
                          ),
                          Text(
                            '₹${earning.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd MMM yyyy').format(earning.date),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          if (earning.paymentMethod != null && earning.paymentMethod!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300, width: 0.8),
                              ),
                              child: Text(
                                earning.paymentMethod!,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (earning.buyerName != null && earning.buyerName!.isNotEmpty) ...[
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Buyer: ${earning.buyerName!}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (earning.quantity != null) ...[
                    const Icon(Icons.scale, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${earning.quantity} ${earning.unit ?? ""}${earning.ratePerUnit != null ? " @ ₹${earning.ratePerUnit}" : ""}',
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ],
                ],
              ),
            ),
            if (earning.note != null && earning.note!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                earning.note!,
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
              ),
            ],
            const Divider(height: 16, thickness: 0.6),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _deleteEarning(earning),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🥥🌴⚪', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'No Byproduct Earnings Recorded',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap "+ Record Earning" below to track income from selling Thotti (Shell), Mattai (Husk), or Paruppu (Raw Coconut).',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
