import 'package:intl/intl.dart';

class Trader {
  final int id;
  final String name;
  final String? phone;
  final String? location;
  final double totalSaleAmount;
  final double totalReceived;
  final double remainingAmount;
  final String? note;
  final DateTime createdAt;

  Trader({
    required this.id,
    required this.name,
    this.phone,
    this.location,
    required this.totalSaleAmount,
    required this.totalReceived,
    required this.remainingAmount,
    this.note,
    required this.createdAt,
  });

  factory Trader.fromJson(Map<String, dynamic> json) {
    return Trader(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      totalSaleAmount: (json['totalSaleAmount'] as num).toDouble(),
      totalReceived: (json['totalReceived'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class TraderTransaction {
  final int id;
  final int traderId;
  final String traderName;
  final double amountReceived;
  final DateTime date;
  final String? paymentMethod;
  final String? note;
  final DateTime createdAt;

  TraderTransaction({
    required this.id,
    required this.traderId,
    required this.traderName,
    required this.amountReceived,
    required this.date,
    this.paymentMethod,
    this.note,
    required this.createdAt,
  });

  factory TraderTransaction.fromJson(Map<String, dynamic> json) {
    return TraderTransaction(
      id: json['id'] as int,
      traderId: json['traderId'] as int,
      traderName: json['traderName'] as String,
      amountReceived: (json['amountReceived'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
}

class CoconutSummary {
  final double totalFarmerPurchase;
  final double totalFarmerPaid;
  final double farmerPending;
  final double totalTraderSales;
  final double totalTraderReceived;
  final double traderPending;

  CoconutSummary({
    required this.totalFarmerPurchase,
    required this.totalFarmerPaid,
    required this.farmerPending,
    required this.totalTraderSales,
    required this.totalTraderReceived,
    required this.traderPending,
  });

  factory CoconutSummary.fromJson(Map<String, dynamic> json) {
    return CoconutSummary(
      totalFarmerPurchase:
          (json['totalFarmerPurchase'] as num).toDouble(),
      totalFarmerPaid: (json['totalFarmerPaid'] as num).toDouble(),
      farmerPending: (json['farmerPending'] as num).toDouble(),
      totalTraderSales: (json['totalTraderSales'] as num).toDouble(),
      totalTraderReceived:
          (json['totalTraderReceived'] as num).toDouble(),
      traderPending: (json['traderPending'] as num).toDouble(),
    );
  }
}
