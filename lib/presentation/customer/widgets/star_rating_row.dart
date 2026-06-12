import 'package:flutter/material.dart';

class StarRatingRow extends StatelessWidget {
  final double averageRating;
  final int reviewCount;
  final VoidCallback? onTap;
  final double iconSize;
  final double textSize;
  final double countSize;

  const StarRatingRow({
    super.key,
    required this.averageRating,
    required this.reviewCount,
    this.onTap,
    this.iconSize = 16,
    this.textSize = 14,
    this.countSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (reviewCount == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber, size: iconSize),
          const SizedBox(width: 2),
          Text(
            averageRating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '($reviewCount)',
            style: TextStyle(fontSize: countSize, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
