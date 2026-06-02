import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/login_page.dart';

class SplashPage extends StatefulWidget {

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {

    super.initState();

    Timer(

      const Duration(seconds: 3),

      () {

        Navigator.pushReplacement(

          context,

          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Container(

              width: 120,
              height: 120,

              decoration: BoxDecoration(

                color: const Color(0xFFD4AF37),

                borderRadius: BorderRadius.circular(30),
              ),

              child: const Icon(
                Icons.shopping_bag,
                size: 70,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 30),

            const Text(

              "PasarKita",

              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(

              "Premium Marketplace App",

              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}