import 'package:intl/intl.dart';

class Farmer {
  final int id;
  final String name;
  final String? phone;
  final String? location;
  final double totalPurchaseAmount;
  final double totalPaid;
  final double remainingAmount;
  final String? note;
  final DateTime createdAt;

  Farmer({
    required this.id,
    required this.name,
    this.phone,
    this.location,
    required this.totalPurchaseAmount,
    required this.totalPaid,
    required this.remainingAmount,
    this.note,
    required this.createdAt,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      totalPurchaseAmount:
          (json['totalPurchaseAmount'] as num).toDouble(),
      totalPaid: (json['totalPaid'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class FarmerTransaction {
  final int id;
  final int farmerId;
  final String farmerName;
  final double amountGiven;
  final DateTime date;
  final String? paymentMethod;
  final String? note;
  final DateTime createdAt;

  FarmerTransaction({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.amountGiven,
    required this.date,
    this.paymentMethod,
    this.note,
    required this.createdAt,
  });

  factory FarmerTransaction.fromJson(Map<String, dynamic> json) {
    return FarmerTransaction(
      id: json['id'] as int,
      farmerId: json['farmerId'] as int,
      farmerName: json['farmerName'] as String,
      amountGiven: (json['amountGiven'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(date);
}
