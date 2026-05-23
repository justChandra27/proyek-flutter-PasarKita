import 'package:flutter/material.dart';

class SizeSelector extends StatelessWidget {

  final String size;

  const SizeSelector({
    super.key,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(right: 12),

      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(12),

        border: Border.all(
          color: const Color(0xFFD4AF37),
        ),
      ),

      child: Text(

        size,

        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}