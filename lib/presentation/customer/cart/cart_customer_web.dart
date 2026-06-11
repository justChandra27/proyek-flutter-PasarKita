//lib/presentation/customer/cart/cart_customer_web.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/cart_model.dart';
import '../../../providers/cart_provider.dart';
import '../../checkout/checkout_page.dart';

class CartCustomerWeb extends StatelessWidget {
  const CartCustomerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const Center(child: Text("Keranjang kosong"));
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // SEARCH
                SizedBox(
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText:
                          "Cari produk di PasarKita...",
                      prefixIcon:
                          const Icon(Icons.search),
                      filled: true,
                      fillColor:
                          const Color(0xffE2E8F0),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Keranjang Belanja",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2563EB),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // LIST CART
                      Expanded(
                        flex: 3,
                        child: ListView(
                          children: cart.items
                              .map(
                                (item) => Padding(
                                  padding:
                                      const EdgeInsets.only(
                                          bottom: 16),
                                  child: _CartItem(
                                    item: item,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),

                      const SizedBox(width: 24),

                      // SUMMARY
                      Container(
                        width: 300,
                        padding:
                            const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xffDBEAFE),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Ringkasan Pesanan",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(0xff2563EB),
                              ),
                            ),

                            const SizedBox(
                                height: 24),

                            _summaryRow(
                              "Subtotal (${cart.itemCount} item)",
                              _formatPrice(
                                  cart.totalPrice),
                            ),

                            const SizedBox(height: 12),

                            _summaryRow(
                              "Pengiriman",
                              "Gratis",
                              valueColor: Colors.green,
                            ),

                            const Divider(height: 40),

                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    "Total Biaya",
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatPrice(
                                      cart.totalPrice),
                                  style:
                                      const TextStyle(
                                    fontSize: 22,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Color(
                                        0xff2563EB),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child:
                                  ElevatedButton.icon(
                                style: ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                      const Color(
                                          0xff2563EB),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CheckoutPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Checkout Sekarang",
                                  style: TextStyle(
                                    color:
                                        Colors.white,
                                    fontWeight:
                                        FontWeight
                                            .bold,
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
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatPrice(int price) {
    final p = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

  Widget _summaryRow(
    String title,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartModel item;

  const _CartItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          const SizedBox(),
                    ),
                  )
                : const SizedBox(),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: 90,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xffE2E8F0),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () => context
                            .read<CartProvider>()
                            .updateQuantity(
                              item.productId,
                              item.quantity - 1,
                            ),
                        child: const Text("-"),
                      ),
                      Text("${item.quantity}"),
                      GestureDetector(
                        onTap: () => context
                            .read<CartProvider>()
                            .updateQuantity(
                              item.productId,
                              item.quantity + 1,
                            ),
                        child: const Text("+"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => context
                    .read<CartProvider>()
                    .removeItem(item.productId),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.black54,
                ),
              ),
              Text(
                _formatPrice(item.price),
                style: const TextStyle(
                  color: Color(0xff2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final p = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }
}
