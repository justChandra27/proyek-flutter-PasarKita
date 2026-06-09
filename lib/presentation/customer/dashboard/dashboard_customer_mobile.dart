//lib/cutomer/dashboard/dashboard_customer_mobile.dart

import 'package:flutter/material.dart';

class DashboardCustomerMobile extends StatelessWidget {
  const DashboardCustomerMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "PasarKita",
                style: TextStyle(
                  color: Color(0xff2563EB),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _promoBanner(),

              const SizedBox(height: 18),

              _searchBox(),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Text(
                    "Kategori",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Lihat Semua",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection:
                      Axis.horizontal,
                  children: [
                    _category(
                      "Hoodie",
                      true,
                    ),
                    _category(
                      "Jacket",
                      false,
                    ),
                    _category(
                      "Shoes",
                      false,
                    ),
                    _category(
                      "T-Shirt",
                      false,
                    ),
                    _category(
                      "Celana",
                      false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Text(
                    "Produk Terbaru",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                              12),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.62,
                children: [
                  _productCard(
                    "Baju Kaos",
                    "Rp 250.000",
                    Icons.checkroom,
                  ),
                  _productCard(
                    "celana jeans",
                    "Rp 100.000",
                    Icons.shopping_bag,
                  ),
                  _productCard(
                    "jaket puff",
                    "Rp 200.000",
                    Icons.hiking,
                  ),
                  _productCard(
                    "batik merah pria",
                    "Rp 150.000",
                    Icons.person,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _promoBanner() {
    return Container(
      height: 190,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff0F56B3),
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  "Premium\nFashion",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight:
                        FontWeight.bold,
                    height: 1,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Discover your style",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          CircleAvatar(
            radius: 34,
            backgroundColor:
                Colors.white24,
            child: Icon(
              Icons.shopping_bag,
              size: 34,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Cari produk...",
        prefixIcon:
            const Icon(Icons.search),
        filled: true,
        fillColor:
            const Color(0xffE8EEF9),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _category(
    String title,
    bool active,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(right: 10),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xff2563EB)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(25),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: active
                ? Colors.white
                : Colors.black87,
            fontWeight:
                active ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  Widget _productCard(
    String title,
    String price,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 60,
                  color: Colors.black54,
                ),
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  price,
                  style: const TextStyle(
                    color:
                        Color(0xff2563EB),
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  "Stok: 10",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                              0xff2563EB),
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                12),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.shopping_cart,
                      size: 16,
                    ),
                    label: const Text(
                      "Beli Sekarang",
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