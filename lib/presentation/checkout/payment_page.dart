import 'package:flutter/material.dart';

import 'success_page.dart';

class PaymentPage extends StatelessWidget {

  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Pembayaran"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color: const Color(0xFF1A1A1A),

                borderRadius: BorderRadius.circular(20),
              ),

              child: const Column(

                children: [

                  Icon(
                    Icons.qr_code,
                    size: 120,
                    color: Color(0xFFD4AF37),
                  ),

                  SizedBox(height: 20),

                  Text(

                    "Scan QR untuk pembayaran",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Midtrans / QRIS / Transfer Bank",
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton(

                style: ElevatedButton.styleFrom(

                  backgroundColor: const Color(0xFFD4AF37),

                  foregroundColor: Colors.black,
                ),

                onPressed: () {

                  Navigator.pushReplacement(

                    context,

                    MaterialPageRoute(
                      builder: (_) => const SuccessPage(),
                    ),
                  );
                },

                child: const Text(

                  "Saya Sudah Bayar",

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