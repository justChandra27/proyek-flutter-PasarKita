import 'package:flutter/material.dart';

class FormLaporanWeb extends StatelessWidget {
  const FormLaporanWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Laporan Analytics",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 260,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari laporan...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  const Badge(
                    child: Icon(
                      Icons.circle,
                      color: Colors.red,
                      size: 10,
                    ),
                  ),

                  const SizedBox(width: 20),

                  const CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150",
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Admin Utama",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Administrator",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // STAT CARD
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      Icons.payments_outlined,
                      "Total Penjualan",
                      "Rp 128.4M",
                      "+12.5% dari bulan lalu",
                      Colors.green,
                      Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _statCard(
                      Icons.shopping_cart_checkout,
                      "Pesanan Selesai",
                      "1,240",
                      "+4.2% dari bulan lalu",
                      Colors.green,
                      Colors.purple,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _statCard(
                      Icons.person_add_alt_1,
                      "Pengguna Baru",
                      "482",
                      "Stabil",
                      Colors.black54,
                      Colors.orange,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: _statCard(
                      Icons.show_chart,
                      "Rata Transaksi",
                      "Rp 103rb",
                      "-1.8% dari bulan lalu",
                      Colors.red,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _revenueChart(),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: _topProducts(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _userGrowth(),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: _categoryChart(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color subtitleColor,
    Color iconColor,
  ) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                iconColor.withOpacity(.15),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
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
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _revenueChart() {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Grafik Pendapatan",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Visualisasi performa harian periode ini",
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                      0xffEEF4FF),
                  borderRadius:
                      BorderRadius.circular(
                          8),
                ),
                child: const Text(
                  "7 Hari",
                  style: TextStyle(
                    color:
                        Color(0xff2563EB),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              const Text("30 Hari"),
            ],
          ),

          const SizedBox(height: 25),

          Expanded(
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                _bar(90),
                _bar(160),
                _bar(120),
                _bar(210),
                _bar(175),
                _bar(225),
                _bar(145),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double height) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xff2563EB),
                Color(0xff93C5FD),
              ],
            ),
            borderRadius:
                BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _topProducts() {
    return Container(
      height: 420,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            "Produk Terlaris",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          _productItem(
            "Nike Air Zoom",
            "Rp 1.4M",
          ),

          _productItem(
            "Apple Watch S8",
            "Rp 980jt",
          ),

          _productItem(
            "Sony WH-1000XM5",
            "Rp 720jt",
          ),

          const Spacer(),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize:
                  const Size(double.infinity, 50),
            ),
            onPressed: () {},
            child: const Text(
              "Lihat Semua Produk",
            ),
          )
        ],
      ),
    );
  }

  Widget _productItem(
    String title,
    String price,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius:
              BorderRadius.circular(10),
        ),
      ),
      title: Text(title),
      subtitle: const Text(
        "Fashion • 242 terjual",
      ),
      trailing: Text(
        price,
        style: const TextStyle(
          color: Color(0xff2563EB),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _userGrowth() {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "Pertumbuhan Pengguna",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "+4,210",
            style: TextStyle(
              fontSize: 32,
              color: Color(0xff2563EB),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("Tahun ini"),
        ],
      ),
    );
  }

  Widget _categoryChart() {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            "Proporsi Kategori",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 30),
          Text("Elektronik 45%"),
          SizedBox(height: 12),
          Text("Fashion 25%"),
          SizedBox(height: 12),
          Text("Hobi & Lainnya 30%"),
        ],
      ),
    );
  }
}