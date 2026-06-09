//lib/presentation/seller/orders/form_pesanan_seller_web.dart

import 'package:flutter/material.dart';

class FormPesananSellerWeb extends StatelessWidget {
  const FormPesananSellerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari pesanan...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Andi Setiawan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Verified Merchant",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // TITLE
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kelola Pesanan",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Pantau dan proses pesanan pelanggan Anda secara efisien.",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.download,
                    color: Color(0xff2563EB),
                  ),
                  label: const Text(
                    "Ekspor Rekap",
                    style: TextStyle(
                      color: Color(0xff2563EB),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // STAT CARD
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    Icons.assignment_turned_in_outlined,
                    "Perlu Diproses",
                    "24 Pesanan",
                    Colors.green,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    Icons.local_shipping_outlined,
                    "Sedang Dikirim",
                    "12 Pesanan",
                    Colors.orange,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    Icons.payments_outlined,
                    "Total Penjualan",
                    "Rp 12.450.000",
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // TAB
                    Container(
                      height: 50,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          _tab(
                            "Semua",
                            true,
                          ),
                          _tab(
                            "Perlu Diproses (24)",
                            false,
                          ),
                          _tab(
                            "Dikirim (12)",
                            false,
                          ),
                          _tab(
                            "Selesai (156)",
                            false,
                          ),
                          _tab(
                            "Dibatalkan",
                            false,
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration:
                                  InputDecoration(
                                hintText:
                                    "Cari nama pembeli atau no. pesanan",
                                prefixIcon:
                                    const Icon(
                                  Icons.search,
                                ),
                                filled: true,
                                fillColor:
                                    const Color(
                                        0xffF8FAFC),
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration:
                                BoxDecoration(
                              border: Border.all(
                                color: Colors
                                    .grey.shade300,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          10),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  "Urutkan: Terbaru",
                                ),
                                SizedBox(
                                    width: 5),
                                Icon(Icons
                                    .keyboard_arrow_down),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            padding:
                                const EdgeInsets.all(
                                    14),
                            decoration:
                                BoxDecoration(
                              border: Border.all(
                                color: Colors
                                    .grey.shade300,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          10),
                            ),
                            child: const Icon(
                              Icons.tune,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        children: [
                          _orderItem(
                            orderId:
                                "#ORD-20230521-001",
                            product:
                                "Sneaker Performance - Stealth Edition",
                            customer:
                                "Budi Santoso",
                            status:
                                "PERLU DIPROSES",
                            statusColor:
                                Colors.green,
                            price:
                                "Rp 850.000",
                            button:
                                "Proses Pesanan",
                          ),

                          _orderItem(
                            orderId:
                                "#ORD-20230521-002",
                            product:
                                "Minimalist White Watch - Series 2",
                            customer:
                                "Siti Aminah",
                            status:
                                "DIKIRIM",
                            statusColor:
                                Colors.orange,
                            price:
                                "Rp 1.200.000",
                            button:
                                "Lacak Resi",
                          ),

                          _orderItem(
                            orderId:
                                "#ORD-20230520-098",
                            product:
                                "Studio Headphones Pro - Jet Black",
                            customer:
                                "Andhika Pratama",
                            status:
                                "SELESAI",
                            statusColor:
                                Colors.blueGrey,
                            price:
                                "Rp 2.450.000",
                            button:
                                "Lihat Detail",
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text(
                            "Menampilkan 1-10 dari 192 pesanan",
                          ),

                          const Spacer(),

                          _pageButton("<"),
                          _pageButton(
                            "1",
                            active: true,
                          ),
                          _pageButton("2"),
                          _pageButton("3"),

                          const Padding(
                            padding:
                                EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Text("..."),
                          ),

                          _pageButton("13"),
                          _pageButton(">"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                color.withOpacity(.15),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab(
    String title,
    bool active,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        right: 20,
      ),
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),
      decoration: BoxDecoration(
        border: active
            ? const Border(
                bottom: BorderSide(
                  color: Color(0xff1D4ED8),
                  width: 2,
                ),
              )
            : null,
      ),
      child: Text(
        title,
        style: TextStyle(
          color: active
              ? const Color(0xff1D4ED8)
              : Colors.black54,
          fontWeight: active
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _orderItem({
    required String orderId,
    required String product,
    required String customer,
    required String status,
    required Color statusColor,
    required String price,
    required String button,
  }) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      leading: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
      title: Row(
        children: [
          Text(
            orderId,
            style: const TextStyle(
              color: Color(0xff1D4ED8),
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(width: 10),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color:
                  statusColor.withOpacity(.15),
              borderRadius:
                  BorderRadius.circular(
                      20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        "$product\nPembeli: $customer",
      ),
      trailing: SizedBox(
        width: 170,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color: Color(
                        0xff1D4ED8),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                        0xff1D4ED8),
              ),
              onPressed: () {},
              child: Text(
                button,
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                ),
              ),
            ),

            const SizedBox(width: 8),

            const Icon(
              Icons.more_vert,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageButton(
    String text, {
    bool active = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        left: 6,
      ),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: active
            ? const Color(
                0xff1D4ED8)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color:
              Colors.grey.shade300,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: active
                ? Colors.white
                : Colors.black,
          ),
        ),
      ),
    );
  }
}