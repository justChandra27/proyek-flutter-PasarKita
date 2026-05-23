import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {

  final Color color;

  const ColorSelector({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(right: 12),

      width: 40,
      height: 40,

      decoration: BoxDecoration(

        color: color,

        shape: BoxShape.circle,

        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
}