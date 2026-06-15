//lib/presentation/seller/products/form_produk_seller_web.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

// import 'widgets/product_table.dart';
import 'widgets/seller_product_builder.dart';
import 'product_form_page.dart';
import 'widgets/product_table_modern.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';

class FormProdukSellerWeb extends StatefulWidget {
  const FormProdukSellerWeb({super.key});

  @override
  State<FormProdukSellerWeb> createState() => _FormProdukSellerWebState();
}

class _FormProdukSellerWebState extends State<FormProdukSellerWeb> {
  String searchQuery = '';
  String selectedStatus = 'Semua';
  String selectedCategory = 'Semua';
  String sortBy = 'Terbaru';
  String _sellerName = 'Seller';
  String _initial = 'S';

  @override
  void initState() {
    super.initState();
    _loadSeller();
  }

  Future<void> _loadSeller() async {
    try {
      final auth = AuthServiceAppwrite();
      final account = await auth.getCurrentUser();
      final databases = AppwriteService.databases;
      final result = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('uid', account.$id)],
      );
      final name = account.name;
      if (result.documents.isNotEmpty) {
        final data = result.documents.first.data;
        final displayName = (data['storeName'] as String?)?.isNotEmpty == true
            ? data['storeName'] as String
            : name;
        if (mounted) {
          setState(() {
            _sellerName = displayName;
            _initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _sellerName = name;
            _initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
          });
        }
      }
    } catch (_) {}
  }

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
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Cari produk...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _sellerName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Verified Merchant",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xff2563EB),
                  child: Text(
                    _initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Produk Saya",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Kelola inventaris dan katalog produk toko Anda",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1D4ED8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductFormPage(),
                      ),
                    );

                    if (result == true && mounted) {
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Tambah Produk",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // STATISTIK
            const SizedBox(height: 24),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          DropdownButton<String>(
                            value: selectedStatus,
                            items: const [
                              DropdownMenuItem(
                                value: 'Semua',
                                child: Text('Semua Status'),
                              ),
                              DropdownMenuItem(
                                value: 'Aktif',
                                child: Text('Aktif'),
                              ),
                              DropdownMenuItem(
                                value: 'Nonaktif',
                                child: Text('Nonaktif'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedStatus = value!;
                              });
                            },
                          ),

                          const SizedBox(width: 10),

                          DropdownButton<String>(
                            value: selectedCategory,
                            items: const [
                              DropdownMenuItem(
                                value: 'Semua',
                                child: Text('Semua Kategori'),
                              ),
                              DropdownMenuItem(
                                value: 'Pakaian',
                                child: Text('Pakaian'),
                              ),
                              DropdownMenuItem(
                                value: 'Sepatu',
                                child: Text('Sepatu'),
                              ),
                              DropdownMenuItem(
                                value: 'Aksesoris',
                                child: Text('Aksesoris'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),

                          const SizedBox(width: 10),

                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.tune, size: 18),
                            label: const Text("Filter"),
                          ),

                          const Spacer(),

                          const Text(
                            "Urutkan:",
                            style: TextStyle(color: Colors.black54),
                          ),

                          const SizedBox(width: 10),

                          DropdownButton<String>(
                            value: sortBy,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: 'Terbaru',
                                child: Text('Terbaru'),
                              ),
                              DropdownMenuItem(
                                value: 'Terlama',
                                child: Text('Terlama'),
                              ),
                              DropdownMenuItem(
                                value: 'Harga Tertinggi',
                                child: Text('Harga Tertinggi'),
                              ),
                              DropdownMenuItem(
                                value: 'Harga Terendah',
                                child: Text('Harga Terendah'),
                              ),
                              DropdownMenuItem(
                                value: 'Nama A-Z',
                                child: Text('Nama A-Z'),
                              ),
                              DropdownMenuItem(
                                value: 'Nama Z-A',
                                child: Text('Nama Z-A'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                sortBy = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    Expanded(
                      child: SellerProductBuilder(
                        builder: (context, products) {
                          final totalProduk = products.length;

                          final produkAktif = products
                              .where((p) => p.active)
                              .length;

                          final produkPending = products
                              .where((p) => p.moderationStatus == 'pending')
                              .length;

                          final stokMenipis = products
                              .where((p) => p.stock <= 5)
                              .length;
                          final filteredProducts = products.where((product) {
                            final name = product.name.toLowerCase();

                            final category = product.category.toLowerCase();

                            final matchSearch =
                                name.contains(searchQuery) ||
                                category.contains(searchQuery);

                            final matchStatus = selectedStatus == 'Semua'
                                ? true
                                : selectedStatus == 'Aktif'
                                ? product.active
                                : !product.active;

                            final matchCategory = selectedCategory == 'Semua'
                                ? true
                                : product.category == selectedCategory;

                            return matchSearch && matchStatus && matchCategory;
                          }).toList();

                          filteredProducts.sort((a, b) {
                            switch (sortBy) {
                              case 'Harga Tertinggi':
                                return b.price.compareTo(a.price);

                              case 'Harga Terendah':
                                return a.price.compareTo(b.price);

                              case 'Nama A-Z':
                                return a.name.compareTo(b.name);

                              case 'Nama Z-A':
                                return b.name.compareTo(a.name);

                              default:
                                return 0;
                            }
                          });

                          return Column(
                            children: [
                              // STATISTIK
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _statCard(
                                        Icons.inventory_2_outlined,
                                        "Total Produk",
                                        totalProduk.toString(),
                                        Colors.blue,
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: _statCard(
                                        Icons.check_circle_outline,
                                        "Produk Aktif",
                                        produkAktif.toString(),
                                        Colors.green,
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: _statCard(
                                        Icons.warning_amber_outlined,
                                        "Stok Menipis",
                                        stokMenipis.toString(),
                                        Colors.red,
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: _statCard(
                                        Icons.hourglass_empty,
                                        "Menunggu Review",
                                        produkPending.toString(),
                                        Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: filteredProducts.isEmpty
                                    ? const Center(
                                        child: Text("Belum ada produk"),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ProductTableModern(
                                            products: filteredProducts,
                                            onProductChanged: () =>
                                                setState(() {}),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          );
                        },
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

  Widget _statCard(IconData icon, String title, String value, Color color) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.black54)),

                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
