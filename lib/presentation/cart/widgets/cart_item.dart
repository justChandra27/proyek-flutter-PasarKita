import 'package:flutter/material.dart';

import 'quantity_button.dart';

class CartItem extends StatelessWidget {

  final String name;
  final String image;
  final String price;

  const CartItem({
    super.key,
    required this.name,
    required this.image,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: const Color(0xFF1A1A1A),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(

        children: [

          // IMAGE
          ClipRRect(

            borderRadius: BorderRadius.circular(16),

            child: Image.network(
              image,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 15),

          // DETAIL
          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  name,

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(

                  price,

                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Row(

                  children: [

                    const QuantityButton(
                      icon: Icons.remove,
                    ),

                    const SizedBox(width: 12),

                    const Text(
                      "1",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const QuantityButton(
                      icon: Icons.add,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}