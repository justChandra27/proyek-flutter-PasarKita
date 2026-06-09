//lib/presentation/customer/cart/cart_customer_mobile.dart

import 'package:flutter/material.dart';

class CartCustomerMobile extends StatelessWidget {
  const CartCustomerMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "Keranjang Saya",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Anda memiliki 3 item dalam keranjang",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Bersihkan Keranjang",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _cartItem(
                "Baju Kaos Premium",
                "Size: L | Color: Obsidian Blue",
                "Rp 250.000",
                Icons.checkroom,
              ),

              const SizedBox(height: 12),

              _cartItem(
                "Celana Jeans Slim Fit",
                "Size: 32 | Color: Sky Denim",
                "Rp 100.000",
                Icons.shopping_bag,
              ),

              const SizedBox(height: 12),

              _cartItem(
                "Jacket Bomber Limited",
                "Size: XL | Color: Midnight Matte",
                "Rp 450.000",
                Icons.hiking,
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Catatan Pesanan",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      maxLines: 3,
                      decoration:
                          InputDecoration(
                        hintText:
                            "Contoh: Titip di satpam ya...",
                        filled: true,
                        fillColor:
                            const Color(
                                0xffF5F7FB),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      const Color(0xffEAF1FF),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment:
                          Alignment.centerLeft,
                      child: Text(
                        "Ringkasan Belanja",
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _summaryRow(
                      "Subtotal (3 item)",
                      "Rp 800.000",
                    ),

                    const SizedBox(height: 8),

                    _summaryRow(
                      "Biaya Pengiriman",
                      "GRATIS",
                      valueColor:
                          Colors.green,
                    ),

                    const SizedBox(height: 8),

                    _summaryRow(
                      "Biaya Layanan",
                      "Rp 2.000",
                    ),

                    const Divider(height: 30),

                    Row(
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const Spacer(),

                        const Text(
                          "Rp 802.000",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                            color: Color(
                                0xff2563EB),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                                  0xff2563EB),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                                    12),
                          ),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Checkout Sekarang",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartItem(
    String title,
    String variant,
    String price,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color:
                      Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      variant,
                      style:
                          const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      price,
                      style:
                          const TextStyle(
                        color:
                            Color(0xff2563EB),
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color:
                      const Color(
                          0xffEEF3FF),
                  borderRadius:
                      BorderRadius.circular(
                          30),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                          Icons.remove),
                    ),

                    const Text(
                      "1",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon:
                          const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 18,
            ),
            label: const Text(
              "Hapus",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    Color valueColor = Colors.black87,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}