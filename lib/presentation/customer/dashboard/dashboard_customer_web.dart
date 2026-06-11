//lib/presentation/customer/dashboard/dashboard_customer_web.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/product_service_appwrite.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../providers/cart_provider.dart';

class DashboardCustomerWeb extends StatefulWidget {
  const DashboardCustomerWeb({super.key});

  @override
  State<DashboardCustomerWeb> createState() =>
      _DashboardCustomerWebState();
}

class _DashboardCustomerWebState
    extends State<DashboardCustomerWeb> {
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
              child: FutureBuilder<List<ProductModel>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Gagal memuat produk",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  final products =
                      snapshot.data ?? [];

                  if (products.isEmpty) {
                    return const Center(
                      child: Text("Belum ada produk"),
                    );
                  }

                  return GridView.count(
                    crossAxisCount: 4,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.75,
                    children: products
                        .map((product) =>
                            _productCard(product))
                        .toList(),
                  );
                },
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
    ProductModel product,
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
              child: product.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) =>
                            const SizedBox(),
                      ),
                    )
                  : const SizedBox(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(
                    color: Color(0xff2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text("Stok: ${product.stock}"),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xff2563EB),
                    ),
                    onPressed: () {
                      context
                          .read<CartProvider>()
                          .addItem(CartModel(
                        productId: product.id,
                        sellerId: product.sellerId,
                        name: product.name,
                        price:
                            product.price.toInt(),
                        imageUrl: product.imageUrl,
                      ));
                      ScaffoldMessenger.of(
                              context)
                          .showSnackBar(SnackBar(
                        content: Text(
                          '${product.name} ditambahkan ke keranjang',
                        ),
                        duration:
                            Duration(seconds: 2),
                      ));
                    },
                    child: const Text(
                      "Tambah ke Keranjang",
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