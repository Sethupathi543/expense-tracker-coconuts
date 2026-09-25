import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Coconut Expense Tracker';
  static const String currency = '₹';

  // Compile-time environment variable: --dart-define=API_URL=https://...
  static const String _configuredApiUrl = String.fromEnvironment('API_URL');

  // Base API URL
  // Uses 10.0.2.2 for Android emulator, localhost for web/desktop local dev,
  // same-origin /api or configured URL when hosted on Vercel/web.
  static String get defaultBaseUrl {
    if (_configuredApiUrl.isNotEmpty) {
      return _configuredApiUrl;
    }

    if (kIsWeb) {
      final host = Uri.base.host;
      if (host.isEmpty || host == 'localhost' || host == '127.0.0.1') {
        return 'http://localhost:8080/api';
      }
      // When hosted on Vercel or custom domain, default to same-origin /api proxy
      return '${Uri.base.origin}/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // With 'adb reverse tcp:8080 tcp:8080', USB-connected phone connects directly to laptop backend!
      return 'http://localhost:8080/api';
    }
    return 'http://localhost:8080/api';
  }

  // Pre-configured default categories
  static const List<String> categories = [
    'Labour',
    'Transport',
    'Coconut',
    'Fuel',
    'Food',
    'Alcohol',
    'Other',
  ];

  // Pre-configured payment methods
  static const List<String> paymentMethods = [
    'Cash',
    'UPI',
    'Bank Transfer',
    'Other',
  ];

  // Colors
  static const Color primaryGreen = Color(0xFF2E7D32); // Lush coconut palm green
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color coconutBrown = Color(0xFF6D4C41);
  static const Color accentAmber = Color(0xFFFFA000);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF212121);
  static const Color textMuted = Color(0xFF757575);

  // Category Icon & Color Mapping
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'labour':
        return Icons.people_alt_rounded;
      case 'transport':
        return Icons.local_shipping_rounded;
      case 'coconut':
        return Icons.park_rounded;
      case 'fuel':
        return Icons.local_gas_station_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'alcohol':
        return Icons.liquor_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'labour':
        return const Color(0xFFE65100); // Deep Orange
      case 'transport':
        return const Color(0xFF1976D2); // Blue
      case 'coconut':
        return const Color(0xFF6D4C41); // Coconut Brown
      case 'fuel':
        return const Color(0xFFD32F2F); // Red
      case 'food':
        return const Color(0xFF7B1FA2); // Purple
      case 'alcohol':
        return const Color(0xFFAD1457); // Deep Pink / Wine
      default:
        return const Color(0xFF616161); // Grey
    }
  }

  static String getCategoryEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'labour':
        return '👷';
      case 'transport':
        return '🚚';
      case 'coconut':
        return '🥥';
      case 'fuel':
        return '⛽';
      case 'food':
        return '🍲';
      case 'alcohol':
        return '🍾';
      default:
        return '📦';
    }
  }

  static String getCategoryDescription(String category) {
    switch (category.toLowerCase()) {
      case 'labour':
        return 'Field work & climbers';
      case 'transport':
        return 'Lorry, tractor & logistics';
      case 'coconut':
        return 'Purchase & coconut trade';
      case 'fuel':
        return 'Diesel, petrol & fuel';
      case 'food':
        return 'Meals, snacks & drinks';
      case 'alcohol':
        return 'Beverages & liquor';
      default:
        return 'General miscellaneous';
    }
  }
}
