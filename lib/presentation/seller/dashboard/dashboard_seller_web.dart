//lib/presentation/seller/dashboard/dashboard_seller_web.dart

import 'package:flutter/material.dart';

class DashboardSellerWeb extends StatelessWidget {
  const DashboardSellerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _header(),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ringkasan Merchant",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Selamat datang kembali, mari lihat perkembangan toko Anda hari ini.",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Total Produk",
                    "120",
                    "+5%",
                    Icons.inventory_2_outlined,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    "Pesanan Baru",
                    "24",
                    "URGENT",
                    Icons.shopping_cart_outlined,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    "Produk Terjual",
                    "87",
                    "+12%",
                    Icons.sell_outlined,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    "Total Omzet",
                    "Rp 12.500.000",
                    "+8%",
                    Icons.payments_outlined,
                    Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _latestProducts(),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: _quickMenu(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari pesanan atau produk...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 20),

        const Text(
          "Andi Setiawan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(width: 10),

        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(
            "https://i.pravatar.cc/150",
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    String growth,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor:
                color.withValues(alpha: .15),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(title),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            growth,
            style: const TextStyle(
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _latestProducts() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const ListTile(
            title: Text(
              "Produk Terbaru",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Text(
              "Lihat Semua",
              style: TextStyle(
                color: Color(0xff2563EB),
              ),
            ),
          ),

          const Divider(height: 1),

          _product(
            "Smart Watch Pro Series 5",
            "Rp 2.450.000",
          ),

          _product(
            "Ultra-Light Runner X",
            "Rp 899.000",
          ),

          _product(
            "PureSound Wireless ANC",
            "Rp 3.100.000",
          ),
        ],
      ),
    );
  }

  Widget _product(
    String title,
    String price,
  ) {
    return ListTile(
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius:
              BorderRadius.circular(8),
        ),
      ),
      title: Text(title),
      subtitle: const Text("Elektronik"),
      trailing: Text(
        price,
        style: const TextStyle(
          color: Color(0xff2563EB),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _quickMenu() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: const [
          _QuickItem("Tambah Produk", Icons.add_box),
          _QuickItem("Laporan", Icons.bar_chart),
          _QuickItem("Promosi", Icons.campaign),
          _QuickItem("Pengaturan", Icons.settings),
        ],
      ),
    );
  }
}

class _QuickItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _QuickItem(this.title, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xff2563EB),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}