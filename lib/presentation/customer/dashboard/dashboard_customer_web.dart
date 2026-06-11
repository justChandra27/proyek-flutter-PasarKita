//lib/presentation/customer/dashboard/dashboard_customer_web.dart

import 'package:flutter/material.dart';

class DashboardCustomerWeb extends StatelessWidget {
  const DashboardCustomerWeb({super.key});

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
                  hintText: "Cari produk...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xffE2E8F0),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                _categoryChip("Hoodie", true),
                _categoryChip("Jacket", false),
                _categoryChip("Shoes", false),
                _categoryChip("T-Shirt", false),
                _categoryChip("Celana", false),
              ],
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Produk Terbaru",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "Lihat Semua",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.75,
                children: [
                  _productCard(
                    "Baju Kaos",
                    "Rp 250.000",
                    "Stok: 10",
                  ),
                  _productCard(
                    "Celana Jeans",
                    "Rp 100.000",
                    "Stok: 10",
                  ),
                  _productCard(
                    "Jaket Puff",
                    "Rp 200.000",
                    "Stok: 10",
                  ),
                  _productCard(
                    "Batik Merah Pria",
                    "Rp 150.000",
                    "Stok: 10",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChip(
    String title,
    bool active,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xffDBEAFE)
              : Colors.white,
          border: Border.all(
            color: const Color(0xffCBD5E1),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active
                ? const Color(0xff2563EB)
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _productCard(
    String title,
    String price,
    String stock,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xff2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(stock),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xff2563EB),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Lihat Detail",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}