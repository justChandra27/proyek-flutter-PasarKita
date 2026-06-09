//lib/presentation/customer/orders/pesanan_customer_mobile.dart

import 'package:flutter/material.dart';

class PesananCustomerMobile extends StatelessWidget {
  const PesananCustomerMobile({super.key});

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
                "Pesanan Saya",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Lacak dan kelola semua transaksi Anda di sini.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection:
                      Axis.horizontal,
                  children: [
                    _tab(
                      "Semua",
                      true,
                    ),
                    _tab(
                      "Berlangsung",
                      false,
                    ),
                    _tab(
                      "Dikirim",
                      false,
                    ),
                    _tab(
                      "Selesai",
                      false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _orderCard(
                status: "Sedang Dikirim",
                orderId: "ORD-2891002",
                productName:
                    "Premium Denim Jacket - Midnight Blue",
                detail:
                    "Ukuran: L • 1 Barang",
                price: "Rp 450.000",
                statusColor:
                    const Color(0xff22C55E),
                productIcon:
                    Icons.checkroom,
                primaryButton:
                    "Selesaikan",
                secondaryButton:
                    "Lacak Pesanan",
              ),

              const SizedBox(height: 16),

              _orderCard(
                status: "Selesai",
                orderId: "ORD-2890945",
                productName:
                    "UltraBoost Sport Edition - Scarlet",
                detail:
                    "Ukuran: 42 • 1 Barang",
                price: "Rp 1.299.000",
                statusColor:
                    Colors.grey,
                productIcon:
                    Icons.directions_run,
                primaryButton:
                    "Beli Lagi",
                secondaryButton:
                    "Beri Ulasan",
                finished: true,
              ),

              const SizedBox(height: 16),

              _orderCard(
                status: "Selesai",
                orderId: "ORD-2890812",
                productName:
                    "Heavy Cotton Tee - Onyx Silver",
                detail:
                    "Ukuran: M • 2 Barang",
                price: "Rp 500.000",
                statusColor:
                    Colors.grey,
                productIcon:
                    Icons.checkroom,
                primaryButton:
                    "Beli Lagi",
                secondaryButton:
                    "Lihat Detail",
                finished: true,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(
    String text,
    bool active,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(right: 10),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        color: active
            ? Colors.white
            : Colors.transparent,
        borderRadius:
            BorderRadius.circular(25),
        border: Border.all(
          color: active
              ? const Color(0xff2563EB)
              : Colors.grey.shade300,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: active
                ? const Color(0xff2563EB)
                : Colors.black54,
            fontWeight:
                active ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _orderCard({
    required String status,
    required String orderId,
    required String productName,
    required String detail,
    required String price,
    required Color statusColor,
    required IconData productIcon,
    required String primaryButton,
    required String secondaryButton,
    bool finished = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                finished
                    ? Icons.check_circle_outline
                    : Icons.local_shipping,
                size: 18,
                color: statusColor,
              ),

              const SizedBox(width: 6),

              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                orderId,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color:
                      Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(
                          12),
                ),
                child: Icon(
                  productIcon,
                  size: 36,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      detail,
                      style:
                          const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      price,
                      style:
                          const TextStyle(
                        color:
                            Color(0xff2563EB),
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style:
                      OutlinedButton.styleFrom(
                    minimumSize:
                        const Size(0, 50),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),
                  ),
                  child: Text(
                    secondaryButton,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style:
                      ElevatedButton.styleFrom(
                    minimumSize:
                        const Size(0, 50),
                    backgroundColor:
                        finished
                            ? const Color(
                                0xffDBEAFE)
                            : const Color(
                                0xff2563EB),
                    foregroundColor:
                        finished
                            ? const Color(
                                0xff2563EB)
                            : Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),
                  ),
                  child: Text(
                    primaryButton,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}