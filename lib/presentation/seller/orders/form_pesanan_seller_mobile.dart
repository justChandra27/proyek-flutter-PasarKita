import 'package:flutter/material.dart';
import '../profile/profile_seller_mobile.dart';

class FormPesananSellerMobile extends StatelessWidget {
  const FormPesananSellerMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "PasarKita",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2563EB),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SellerEditProfileMobile(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pesanan",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Kelola pesanan dari pelanggan Anda",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _tab("Semua (24)", true),
                        const SizedBox(width: 8),
                        _tab("Perlu Diproses (5)", false),
                        const SizedBox(width: 8),
                        _tab("Dikirim (8)", false),
                        const SizedBox(width: 8),
                        _tab("Selesai (11)", false),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  OrderCardNew(),

                  SizedBox(height: 16),

                  OrderCardShipping(),

                  SizedBox(height: 16),

                  OrderCardDone(),

                  SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tab(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xff1E40AF) : const Color(0xffDBEAFE),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: active ? Colors.white : Colors.black54,
          fontWeight: active ? FontWeight.bold : null,
        ),
      ),
    );
  }
}

class OrderCardNew extends StatelessWidget {
  const OrderCardNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff1E40AF), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "#PK-98231",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff1E40AF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Pesanan Baru",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Budi Santoso",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _imageBox(Icons.directions_run),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sepatu Lari Pro-Speed X",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "1 x Rp 850.000",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 30),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Total Pesanan",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                const Text(
                  "Rp 865.000",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E40AF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text("Rincian"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1E40AF),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Proses Pesanan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrderCardShipping extends StatelessWidget {
  const OrderCardShipping({super.key});

  @override
  Widget build(BuildContext context) {
    return _shippingCard(
      orderId: "#PK-98229",
      customer: "Siti Aminah",
      product: "Jam Tangan Minimalist Silver",
      qtyPrice: "2 x Rp 450.000",
      total: "Rp 912.000",
      status: "Dalam Pengiriman",
      icon: Icons.watch,
    );
  }
}

class OrderCardDone extends StatelessWidget {
  const OrderCardDone({super.key});

  @override
  Widget build(BuildContext context) {
    return _shippingCard(
      orderId: "#PK-98210",
      customer: "Rian Hidayat",
      product: "Headphone Wireless BassMax",
      qtyPrice: "1 x Rp 1.200.000",
      total: "",
      status: "Selesai",
      icon: Icons.headphones,
      showReview: true,
    );
  }
}

class _shippingCard extends StatelessWidget {
  final String orderId;
  final String customer;
  final String product;
  final String qtyPrice;
  final String total;
  final String status;
  final IconData icon;
  final bool showReview;

  const _shippingCard({
    required this.orderId,
    required this.customer,
    required this.product,
    required this.qtyPrice,
    required this.total,
    required this.status,
    required this.icon,
    this.showReview = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  orderId,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffDBEAFE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xff1E40AF),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              customer,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _imageBox(icon),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(qtyPrice, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 30),

          if (!showReview) ...[
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Total Pesanan",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                Text(
                  total,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("Lacak Pengiriman"),
              ),
            ),
          ],

          if (showReview)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text("Lihat Ulasan"),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _imageBox(IconData icon) {
  return Container(
    width: 70,
    height: 70,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, size: 35, color: Colors.grey.shade700),
  );
}
