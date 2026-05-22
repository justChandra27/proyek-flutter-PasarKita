import 'package:flutter/material.dart';
import '../../core/widgets/product_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("PasarKita"),
      ),

      body: ListView(

        children: [

          Container(

            height: 180,

            margin: const EdgeInsets.all(16),

            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(20),

              gradient: const LinearGradient(

                colors: [
                  Color(0xFFD4AF37),
                  Colors.black,
                ],
              ),
            ),

            child: const Center(

              child: Text(

                "Premium Fashion",

                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}