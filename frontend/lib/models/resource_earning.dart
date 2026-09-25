class ResourceEarning {
  final int id;
  final String resourceType; // 'Thotti' or 'Mattai'
  final double? quantity;
  final String? unit;
  final double? ratePerUnit;
  final double totalAmount;
  final String? buyerName;
  final DateTime date;
  final String? paymentMethod;
  final String? note;
  final DateTime? createdAt;

  ResourceEarning({
    required this.id,
    required this.resourceType,
    this.quantity,
    this.unit,
    this.ratePerUnit,
    required this.totalAmount,
    this.buyerName,
    required this.date,
    this.paymentMethod,
    this.note,
    this.createdAt,
  });

  factory ResourceEarning.fromJson(Map<String, dynamic> json) {
    return ResourceEarning(
      id: (json['id'] as num).toInt(),
      resourceType: json['resourceType'] as String? ?? 'Thotti',
      quantity: json['quantity'] != null ? (json['quantity'] as num).toDouble() : null,
      unit: json['unit'] as String?,
      ratePerUnit: json['ratePerUnit'] != null ? (json['ratePerUnit'] as num).toDouble() : null,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      buyerName: json['buyerName'] as String?,
      date: DateTime.parse(json['date'] as String),
      paymentMethod: json['paymentMethod'] as String?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resourceType': resourceType,
      'quantity': quantity,
      'unit': unit,
      'ratePerUnit': ratePerUnit,
      'totalAmount': totalAmount,
      'buyerName': buyerName,
      'date': date.toIso8601String().split('T').first,
      'paymentMethod': paymentMethod,
      'note': note,
    };
  }
}

class ResourceEarningSummary {
  final double totalEarnings;
  final double thottiEarnings;
  final double mattaiEarnings;
  final double paruppuEarnings;

  ResourceEarningSummary({
    required this.totalEarnings,
    required this.thottiEarnings,
    required this.mattaiEarnings,
    this.paruppuEarnings = 0.0,
  });

  factory ResourceEarningSummary.fromJson(Map<String, dynamic> json) {
    return ResourceEarningSummary(
      totalEarnings: json['totalEarnings'] != null ? (json['totalEarnings'] as num).toDouble() : 0.0,
      thottiEarnings: json['thottiEarnings'] != null ? (json['thottiEarnings'] as num).toDouble() : 0.0,
      mattaiEarnings: json['mattaiEarnings'] != null ? (json['mattaiEarnings'] as num).toDouble() : 0.0,
      paruppuEarnings: json['paruppuEarnings'] != null ? (json['paruppuEarnings'] as num).toDouble() : 0.0,
    );
  }
}
