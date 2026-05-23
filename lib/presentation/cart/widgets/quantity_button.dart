import 'package:flutter/material.dart';

class QuantityButton extends StatelessWidget {

  final IconData icon;

  const QuantityButton({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: 35,
      height: 35,

      decoration: BoxDecoration(

        color: const Color(0xFFD4AF37),

        borderRadius: BorderRadius.circular(10),
      ),

      child: Icon(
        icon,
        color: Colors.black,
        size: 20,
      ),
    );
  }
}