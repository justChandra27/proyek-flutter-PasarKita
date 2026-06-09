import 'package:flutter/material.dart';
import '../profile/profile_seller_mobile.dart';

class MobileSellerDashboard extends StatefulWidget {
  const MobileSellerDashboard({super.key});

  @override
  State<MobileSellerDashboard> createState() => _MobileSellerDashboardState();
}

class _MobileSellerDashboardState extends State<MobileSellerDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Halo, Andi 👋",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Selamat datang kembali",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SellerEditProfileMobile(),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // TOTAL PENJUALAN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xff2563EB), Color(0xff4F46E5)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "TOTAL PENJUALAN",
                            style: TextStyle(
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.payments_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Rp 12.450.000",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "+12.5% dibanding bulan lalu",
                      style: TextStyle(color: Colors.greenAccent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // CARD KECIL
              Row(
                children: [
                  Expanded(
                    child: _miniCard(
                      title: "Pesanan Baru",
                      value: "24",
                      icon: Icons.shopping_bag_outlined,
                      color: const Color(0xffDBEAFE),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _miniCard(
                      title: "Rating",
                      value: "4.8",
                      icon: Icons.star,
                      color: const Color(0xffFEF3C7),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // QUICK ACTION
              const Text(
                "Aksi Cepat",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  QuickAction(
                    icon: Icons.add_box,
                    title: "Tambah Produk",
                    color: Color(0xff2563EB),
                  ),
                  QuickAction(
                    icon: Icons.inventory_2,
                    title: "Produk",
                    color: Color(0xff10B981),
                  ),
                  QuickAction(
                    icon: Icons.shopping_bag,
                    title: "Pesanan",
                    color: Color(0xffF59E0B),
                  ),
                  QuickAction(
                    icon: Icons.chat_bubble,
                    title: "Chat",
                    color: Color(0xff8B5CF6),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // STATUS TOKO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Color(0xffDCFCE7),
                      child: Icon(Icons.verified, color: Colors.green),
                    ),

                    SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Toko Terverifikasi",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Akun Anda telah diverifikasi"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Produk Terbaru",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text("Lihat Semua"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              const ProductCard(title: "Hoodie Premium", price: "Rp 150.000"),

              const SizedBox(height: 12),

              const ProductCard(title: "Sneakers Casual", price: "Rp 250.000"),

              const SizedBox(height: 12),

              const ProductCard(title: "Topi Baseball", price: "Rp 75.000"),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon),
          ),

          const SizedBox(height: 14),

          Text(title),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const QuickAction({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String title;
  final String price;

  const ProductCard({super.key, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.image),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xff2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Aktif",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
