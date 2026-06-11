//lib/cutomer/dashboard/dashboard_customer_mobile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/product_service_appwrite.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../providers/cart_provider.dart';

class DashboardCustomerMobile extends StatefulWidget {
  const DashboardCustomerMobile({super.key});

  @override
  State<DashboardCustomerMobile> createState() =>
      _DashboardCustomerMobileState();
}

class _DashboardCustomerMobileState
    extends State<DashboardCustomerMobile> {
  final ProductServiceAppwrite _productService =
      ProductServiceAppwrite();
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getAllProducts();
  }

  String _formatPrice(double price) {
    final p = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

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

              FutureBuilder<List<ProductModel>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          "Gagal memuat produk",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  }

                  final products =
                      snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          "Belum ada produk",
                        ),
                      ),
                    );
                  }

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.62,
                    children: products
                        .map((product) =>
                            _productCard(product))
                        .toList(),
                  );
                },
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
    ProductModel product,
  ) {
    final outOfStock = product.stock <= 0;
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
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius:
                        const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius:
                              const BorderRadius.vertical(
                            top:
                                Radius.circular(20),
                          ),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __,
                                    ___) =>
                                const Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.image,
                          size: 60,
                          color: Colors.black54,
                        ),
                ),
                if (outOfStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Stok Habis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
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
                  product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(
                    color:
                        Color(0xff2563EB),
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  outOfStock
                      ? "Stok: Habis"
                      : "Stok: ${product.stock}",
                  style: TextStyle(
                    color: outOfStock
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: outOfStock
                      ? ElevatedButton.icon(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.grey,
                            foregroundColor:
                                Colors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: null,
                          icon: const Icon(
                            Icons.shopping_cart,
                            size: 16,
                          ),
                          label: const Text(
                            "Stok Habis",
                          ),
                        )
                      : ElevatedButton.icon(
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xff2563EB),
                            foregroundColor:
                                Colors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            context
                                .read<CartProvider>()
                                .addItem(CartModel(
                              productId: product.id,
                              sellerId: product.sellerId,
                              name: product.name,
                              price: product.price.toInt(),
                              imageUrl: product.imageUrl,
                              stock: product.stock,
                            ));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(
                                '${product.name} ditambahkan ke keranjang',
                              ),
                            ));
                          },
                          icon: const Icon(
                            Icons.shopping_cart,
                            size: 16,
                          ),
                          label: const Text(
                            "Tambah ke Keranjang",
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