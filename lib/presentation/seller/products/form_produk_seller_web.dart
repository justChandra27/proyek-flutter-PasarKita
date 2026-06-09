import 'package:flutter/material.dart';

// import 'widgets/product_table.dart';
import 'widgets/seller_product_builder.dart';
import 'product_form_page.dart';
import 'widgets/product_table_modern.dart';

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

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Seller",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Verified Merchant",
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person),
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
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductFormPage(),
                      ),
                    );

                    if (mounted) {
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
                                        Icons.visibility_outlined,
                                        "Dilihat",
                                        "0",
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
            backgroundColor: color.withOpacity(.15),
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

  Widget _filterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [Text(text), const Icon(Icons.keyboard_arrow_down)]),
    );
  }
}
