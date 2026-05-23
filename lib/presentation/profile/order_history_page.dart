import 'package:flutter/material.dart';

class OrderHistoryPage extends StatelessWidget {

  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Riwayat Pesanan"),
      ),

      body: ListView(

        padding: const EdgeInsets.all(16),

        children: [

          orderItem(
            title: "Premium Hoodie",
            price: "Rp 250.000",
            status: "Selesai",
          ),

          orderItem(
            title: "Luxury Sneakers",
            price: "Rp 550.000",
            status: "Diproses",
          ),
        ],
      ),
    );
  }

  Widget orderItem({

    required String title,
    required String price,
    required String status,
  }) {

    return Container(

      margin: const EdgeInsets.only(bottom: 16),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(

        color: const Color(0xFF1A1A1A),

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Text(

            price,

            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Container(

            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),

            decoration: BoxDecoration(

              color: const Color(0xFFD4AF37),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Text(

              status,

              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}