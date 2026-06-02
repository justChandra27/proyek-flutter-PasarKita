import 'package:flutter/material.dart';

import '../auth/login_page.dart';

class OnboardingPage extends StatelessWidget {

  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Padding(

        padding: const EdgeInsets.all(24),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Container(

              height: 300,

              decoration: BoxDecoration(

                color: const Color(0xFF1A1A1A),

                borderRadius: BorderRadius.circular(30),
              ),

              child: const Center(

                child: Icon(
                  Icons.shopping_bag,
                  size: 120,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ),

            const SizedBox(height: 50),

            const Text(

              "Belanja Fashion Premium",

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(

              "Temukan produk fashion terbaik dengan kualitas premium dan harga terbaik.",

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 50),

            SizedBox(

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

                onPressed: () {

                  Navigator.pushReplacement(

                    context,

                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },

                child: const Text(

                  "Mulai Sekarang",

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}