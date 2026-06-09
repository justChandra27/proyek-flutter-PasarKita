//lib/presentation/admin/products/form_produk_web.dart

import 'package:flutter/material.dart';

class FormProdukWeb extends StatelessWidget {
  const FormProdukWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Manajemen Produk",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                SizedBox(
                  width: 380,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari nama produk atau SKU...",
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

                const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ACTION
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Tambah Produk",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: const Text("Filter"),
                ),

                const Spacer(),

                const Text(
                  "Menampilkan 128 Produk",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 22,
                crossAxisSpacing: 22,
                childAspectRatio: 0.72,
                children: const [
                  ProductCard(
                    image:
                        "https://images.unsplash.com/photo-1542291026-7eec264c27ff",
                    category: "Sepatu Lari",
                    title: "Nike Air Max Pro 2024",
                    price: "Rp 2.499.000",
                    stock: "42",
                    badge: "TERLARIS",
                  ),

                  ProductCard(
                    image:
                        "https://images.unsplash.com/photo-1523170335258-f5ed11844a49",
                    category: "Aksesoris",
                    title: "Minimalist Silver Watch",
                    price: "Rp 1.850.000",
                    stock: "5",
                  ),

                  ProductCard(
                    image:
                        "https://images.unsplash.com/photo-1505740420928-5e560c06d30e",
                    category: "Elektronik",
                    title: "Audio-Technica M50x BT",
                    price: "Rp 3.120.000",
                    stock: "12",
                  ),

                  ProductCard(
                    image:
                        "https://images.unsplash.com/photo-1543508282-6319a3e2621f",
                    category: "Sepatu Casual",
                    title: "Vans Old Skool Yellow",
                    price: "Rp 899.000",
                    stock: "88",
                  ),

                  ProductCard(
                    image:
                        "https://images.unsplash.com/photo-1511499767150-a48a237f0083",
                    category: "Aksesoris",
                    title: "Ray-Ban Aviator Gold",
                    price: "Rp 2.100.000",
                    stock: "15",
                  ),

                  ProductCard(
                    image:
                        "https://images.unsplash.com/photo-1505843513577-22bb7d21e455",
                    category: "Mebel",
                    title: "Ergonomic Mesh Chair",
                    price: "Rp 1.450.000",
                    stock: "24",
                  ),

                  ProductCard(
                    image:
                        "https://images.unsplash.com/photo-1511467687858-23d96c32e4ae",
                    category: "Elektronik",
                    title: "Keychron K2 Wireless",
                    price: "Rp 1.250.000",
                    stock: "31",
                  ),

                  ProductCard(
                    image:
                        "https://images.unsplash.com/photo-1516035069371-29a1b244cc32",
                    category: "Kamera",
                    title: "Fujifilm Instax Mini 11",
                    price: "Rp 950.000",
                    stock: "56",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _pageButton("<", false),
                _pageButton("1", true),
                _pageButton("2", false),
                _pageButton("3", false),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("..."),
                ),
                _pageButton("12", false),
                _pageButton(">", false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _pageButton(
    String text,
    bool active,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xff2563EB)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color:
                active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String image;
  final String category;
  final String title;
  final String price;
  final String stock;
  final String? badge;

  const ProductCard({
    super.key,
    required this.image,
    required this.category,
    required this.title,
    required this.price,
    required this.stock,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
                child: Image.network(
                  image,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              if (badge != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff2563EB),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        price,
                        style: const TextStyle(
                          color: Color(0xff2563EB),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffF3F4F6),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 14,
                            color: Color(0xff2563EB),
                          ),
                          const SizedBox(width: 4),
                          Text(stock),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}