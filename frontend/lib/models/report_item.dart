class CategoryReportItem {
  final String category;
  final double totalAmount;
  final int count;
  final double percentage;

  CategoryReportItem({
    required this.category,
    required this.totalAmount,
    required this.count,
    required this.percentage,
  });

  factory CategoryReportItem.fromJson(Map<String, dynamic> json) {
    return CategoryReportItem(
      category: json['category'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyReportItem {
  final DateTime date;
  final double totalAmount;

  DailyReportItem({
    required this.date,
    required this.totalAmount,
  });

  factory DailyReportItem.fromJson(Map<String, dynamic> json) {
    return DailyReportItem(
      date: DateTime.parse(json['date']),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
