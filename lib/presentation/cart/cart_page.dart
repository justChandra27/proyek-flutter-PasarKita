import 'package:flutter/material.dart';
import '../checkout/checkout_page.dart';
import 'widgets/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang")),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // CART LIST
            Expanded(
              child: ListView(
                children: const [
                  CartItem(
                    name: "Premium Hoodie",
                    image: "https://picsum.photos/300/300",
                    price: "Rp 250.000",
                  ),

                  CartItem(
                    name: "Luxury Sneakers",
                    image: "https://picsum.photos/301/300",
                    price: "Rp 550.000",
                  ),
                ],
              ),
            ),

            // TOTAL SECTION
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),

                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: const [
                      Text(
                        "Total",

                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "Rp 800.000",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),

                        foregroundColor: Colors.black,
                      ),

                      onPressed: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => const CheckoutPage(),
                          ),
                        );
                      },

                      child: const Text(
                        "Checkout",

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
          ],
        ),
      ),
    );
  }
}
