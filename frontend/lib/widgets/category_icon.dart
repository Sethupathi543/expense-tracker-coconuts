import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CategoryIconWidget extends StatelessWidget {
  final String category;
  final double size;
  final double iconSize;

  const CategoryIconWidget({
    super.key,
    required this.category,
    this.size = 46.0,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppConstants.getCategoryColor(category);
    final emoji = AppConstants.getCategoryEmoji(category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: iconSize * 0.95),
        ),
      ),
    );
  }
}
