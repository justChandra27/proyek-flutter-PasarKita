import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {

  final String title;

  const CategoryItem({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(right: 12),

      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),

      decoration: BoxDecoration(

        color: const Color(0xFF1A1A1A),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: const Color(0xFFD4AF37),
        ),
      ),

      child: Text(

        title,

        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}