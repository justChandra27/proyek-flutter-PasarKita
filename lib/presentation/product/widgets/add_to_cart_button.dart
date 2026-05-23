import 'package:flutter/material.dart';

class AddToCartButton extends StatelessWidget {

  const AddToCartButton({super.key});

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,
      height: 55,

      child: ElevatedButton(

        style: ElevatedButton.styleFrom(

          backgroundColor: const Color(0xFFD4AF37),

          foregroundColor: Colors.black,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        onPressed: () {},

        child: const Text(

          "Add To Cart",

          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}