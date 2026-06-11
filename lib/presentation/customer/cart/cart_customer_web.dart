//lib/presentation/customer/cart/cart_customer_web.dart

import 'package:flutter/material.dart';

class CartCustomerWeb extends StatelessWidget {
  const CartCustomerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // SEARCH
            SizedBox(
              height: 50,
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari produk di PasarKita...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xffE2E8F0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Keranjang Belanja",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2563EB),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Anda memiliki 3 item dalam keranjang Anda.",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LIST CART
                  Expanded(
                    flex: 3,
                    child: ListView(
                      children: const [
                        _CartItem(
                          productName:
                              "Baju Kaos Premium Obsidian",
                          variant:
                              "Ukuran: L | Warna: Navy Black",
                          price: "Rp 250.000",
                        ),

                        SizedBox(height: 16),

                        _CartItem(
                          productName:
                              "Celana Jeans Sky Blue Slim",
                          variant:
                              "Ukuran: 32 | Warna: Light Blue",
                          price: "Rp 100.000",
                        ),

                        SizedBox(height: 16),

                        _CartItem(
                          productName:
                              "Jaket Puff Tactical Olive",
                          variant:
                              "Ukuran: XL | Warna: Tactical Green",
                          price: "Rp 200.000",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // SUMMARY
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(20),
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
                            color: Color(0xff2563EB),
                          ),
                        ),

                        const SizedBox(height: 24),

                        _summaryRow(
                          "Subtotal (3 item)",
                          "Rp 550.000",
                        ),

                        const SizedBox(height: 12),

                        _summaryRow(
                          "Pengiriman",
                          "Gratis",
                          valueColor: Colors.green,
                        ),

                        const SizedBox(height: 12),

                        _summaryRow(
                          "Diskon Member",
                          "- Rp 50.000",
                          valueColor: Colors.red,
                        ),

                        const Divider(height: 40),

                        const Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Total Biaya",
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "Rp 500.000",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(0xff2563EB),
                              ),
                            ),
                          ],
                        ),

                        const Align(
                          alignment:
                              Alignment.centerRight,
                          child: Text(
                            "Termasuk PPN 11%",
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.black54,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          padding:
                              const EdgeInsets.all(
                                  16),
                          decoration:
                              BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        14),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons
                                    .local_activity_outlined,
                                color: Color(
                                    0xff2563EB),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      "Gunakan Voucher",
                                      style:
                                          TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                    Text(
                                      "Hemat hingga Rp 50.000 lagi",
                                      style:
                                          TextStyle(
                                        fontSize:
                                            12,
                                        color: Colors
                                            .black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style:
                                ElevatedButton
                                    .styleFrom(
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
                            icon: const Icon(
                              Icons.lock,
                              color:
                                  Colors.white,
                            ),
                            label: const Text(
                              "Checkout Sekarang",
                              style: TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.bold,
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
      ),
    );
  }

  static Widget _summaryRow(
    String title,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(title),
        ),
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
  final String productName;
  final String variant;
  final String price;

  const _CartItem({
    required this.productName,
    required this.variant,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius:
                  BorderRadius.circular(12),
            ),
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
                  productName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  variant,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: 90,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xffE2E8F0),
                    borderRadius:
                        BorderRadius.circular(
                            8),
                  ),
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceEvenly,
                    children: [
                      Text("-"),
                      Text("1"),
                      Text("+"),
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
              const Icon(
                Icons.delete_outline,
                color: Colors.black54,
              ),
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xff2563EB),
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 