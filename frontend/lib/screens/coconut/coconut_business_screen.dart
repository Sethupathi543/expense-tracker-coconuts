import 'package:flutter/material.dart';
import '../../models/trader.dart';
import '../../models/resource_earning.dart';
import '../../services/coconut_business_service.dart';
import '../../utils/constants.dart';
import 'farmer/farmer_list_screen.dart';
import 'trader/trader_list_screen.dart';
import 'resource_earnings_screen.dart';
import 'coconut_analyzer_screen.dart';

class CoconutBusinessScreen extends StatefulWidget {
  const CoconutBusinessScreen({super.key});

  @override
  State<CoconutBusinessScreen> createState() => _CoconutBusinessScreenState();
}

class _CoconutBusinessScreenState extends State<CoconutBusinessScreen> {
  final CoconutBusinessService _service = CoconutBusinessService();
  CoconutSummary? _summary;
  ResourceEarningSummary? _resourceSummary;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _loading = true);
    try {
      final summary = await _service.getSummary();
      final resourceSummary = await _service.getResourceEarningsSummary();
      if (mounted) {
        setState(() {
          _summary = summary;
          _resourceSummary = resourceSummary;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundLight,
      appBar: AppBar(
        title: const Text('Coconut Business',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppConstants.coconutBrown,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadSummary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary card
              _buildSummaryCard(),
              const SizedBox(height: 24),
              const Text('Select Section',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textDark)),
              const SizedBox(height: 16),
              // Four large cards: FARMER, TRADER, BYPRODUCTS, COCONUT ANALYZER
              _buildSectionCard(
                icon: Icons.analytics_rounded,
                title: 'COCONUT ANALYZER',
                subtitle: 'Spending Breakdown by Date, Weekly & Monthly',
                color: const Color(0xFF1565C0),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CoconutAnalyzerScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                icon: Icons.agriculture_rounded,
                title: 'FARMER',
                subtitle: 'Farmer Payments',
                color: const Color(0xFF388E3C),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FarmerListScreen()),
                  );
                  _loadSummary();
                },
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                icon: Icons.storefront_rounded,
                title: 'TRADER',
                subtitle: 'Trader Earnings & Collections',
                color: AppConstants.coconutBrown,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TraderListScreen()),
                  );
                  _loadSummary();
                },
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                icon: Icons.eco_rounded,
                title: 'BYPRODUCTS',
                subtitle: 'Thotti (Endocarp), Mattai (Epicarp) & Paruppu Earnings',
                color: const Color(0xFF4E342E),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ResourceEarningsScreen()),
                  );
                  _loadSummary();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [AppConstants.coconutBrown, Color(0xFF4E342E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.park_rounded,
                          color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text('Coconut Business Summary',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_summary != null) ...[
                    _summaryRow('🌾 Farmer Purchase',
                        _summary!.totalFarmerPurchase),
                    _summaryRow('✅ Farmer Paid', _summary!.totalFarmerPaid),
                    _summaryRow(
                        '⏳ Farmer Pending', _summary!.farmerPending,
                        highlight: true),
                    const Divider(color: Colors.white30, height: 20),
                    _summaryRow(
                        '🛒 Trader Sales', _summary!.totalTraderSales),
                    _summaryRow(
                        '✅ Trader Received', _summary!.totalTraderReceived),
                    _summaryRow(
                        '⏳ Trader Pending', _summary!.traderPending,
                        highlight: true),
                    if (_resourceSummary != null && _resourceSummary!.totalEarnings > 0) ...[
                      const Divider(color: Colors.white30, height: 20),
                      _summaryRow(
                          '🥥 Thotti (Shell) Revenue', _resourceSummary!.thottiEarnings),
                      _summaryRow(
                          '🌴 Mattai (Husk) Revenue', _resourceSummary!.mattaiEarnings),
                      if (_resourceSummary!.paruppuEarnings > 0)
                        _summaryRow(
                            '⚪ Paruppu (Raw) Revenue', _resourceSummary!.paruppuEarnings),
                      _summaryRow(
                          '✨ Byproducts Total Revenue', _resourceSummary!.totalEarnings,
                          highlight: true),
                    ],
                  ] else
                    const Text('No data available',
                        style: TextStyle(color: Colors.white70)),
                ],
              ),
      ),
    );
  }

  Widget _summaryRow(String label, double amount,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: highlight ? Colors.amber[200] : Colors.white70,
                  fontSize: 13)),
          Text('₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  color: highlight ? Colors.amber[200] : Colors.white,
                  fontSize: 14,
                  fontWeight:
                      highlight ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [color, color.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 56, color: Colors.white),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 6),
              Text(subtitle,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
