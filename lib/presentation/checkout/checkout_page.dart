import 'package:flutter/material.dart';


import 'payment_page.dart';

class CheckoutPage extends StatelessWidget {

  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Checkout"),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // ADDRESS
            const Text(

              "Alamat Pengiriman",

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            TextField(

              maxLines: 3,

              decoration: InputDecoration(

                hintText: "Masukkan alamat lengkap",

                filled: true,

                fillColor: const Color(0xFF1A1A1A),

                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(16),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // SHIPPING
            const Text(

              "Metode Pengiriman",

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: const Color(0xFF1A1A1A),

                borderRadius: BorderRadius.circular(16),
              ),

              child: const Row(

                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [

                  Text(
                    "JNE Regular",
                    style: TextStyle(fontSize: 16),
                  ),

                  Text(
                    "Rp 20.000",
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // PAYMENT
            const Text(

              "Metode Pembayaran",

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Container(

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: const Color(0xFF1A1A1A),

                borderRadius: BorderRadius.circular(16),
              ),

              child: const Row(

                children: [

                  Icon(Icons.account_balance_wallet),

                  SizedBox(width: 12),

                  Text("Midtrans / Transfer Bank"),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // TOTAL
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: const [

                Text(

                  "Total Pembayaran",

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(

                  "Rp 820.000",

                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // BUTTON
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

                  Navigator.push(

                    context,

                    MaterialPageRoute(
                      builder: (_) => const PaymentPage(),
                    ),
                  );
                },

                child: const Text(

                  "Lanjut Pembayaran",

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