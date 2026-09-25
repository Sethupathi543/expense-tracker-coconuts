class Expense {
  final int? id;
  final double amount;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    required this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] ?? '',
      date: DateTime.parse(json['date']),
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      note: json['note'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'category': category,
      'date': "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      'paymentMethod': paymentMethod,
      'note': note,
    };
  }
}
