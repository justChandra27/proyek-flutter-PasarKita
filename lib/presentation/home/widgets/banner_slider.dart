import 'package:flutter/material.dart';

class BannerSlider extends StatelessWidget {

  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(

      height: 220,

      margin: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(

          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            Color(0xFFD4AF37),
            Colors.black,
          ],
        ),
      ),

      child: Padding(

        padding: const EdgeInsets.all(24),

        child: Row(

          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            const Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Text(

                  "Premium\nFashion",

                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  "Discover your style",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            const CircleAvatar(

              radius: 40,

              backgroundColor: Colors.white24,

              child: Icon(
                Icons.shopping_bag,
                size: 40,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}