import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {

  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Icon(

                Icons.check_circle,

                size: 140,

                color: Color(0xFFD4AF37),
              ),

              const SizedBox(height: 30),

              const Text(

                "Pembayaran Berhasil",

                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(

                "Pesanan Anda sedang diproses",

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(

                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(

                    backgroundColor: const Color(0xFFD4AF37),

                    foregroundColor: Colors.black,
                  ),

                  onPressed: () {

                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },

                  child: const Text(

                    "Kembali ke Home",

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
      ),
    );
  }
}