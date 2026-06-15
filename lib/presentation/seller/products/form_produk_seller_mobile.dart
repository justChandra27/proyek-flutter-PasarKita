import 'package:flutter/material.dart';

import '../profile/profile_seller_mobile.dart';

import 'widgets/product_card.dart';
import 'widgets/seller_product_builder.dart';
import 'product_form_page.dart';

class FormProdukSellerMobile extends StatefulWidget {
  final String? initialCategory;

  const FormProdukSellerMobile({super.key, this.initialCategory});

  @override
  State<FormProdukSellerMobile> createState() => _FormProdukSellerMobileState();
}

class _FormProdukSellerMobileState extends State<FormProdukSellerMobile> {
  String _selectedFilter = 'semua';
  String _selectedCategory = '';
  String _searchQuery = '';
  String _sortBy = 'harga_tertinggi';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                      if (widget.initialCategory != null) ...[
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Color(0xff2563EB),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
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
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xff2563EB),
                          child: Text(
                            "S",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

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
                            SizedBox(height: 4),
                            Text(
                              "Daftar produk toko Anda",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      ElevatedButton.icon(
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
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Tambah"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1E40AF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Cari produk...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xffF5F7FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _filterChip("Semua", _selectedFilter == 'semua', 'semua'),
                      const SizedBox(width: 8),
                      _filterChip("Aktif", _selectedFilter == 'aktif', 'aktif'),
                      const SizedBox(width: 8),
                      _filterChip("Nonaktif", _selectedFilter == 'nonaktif', 'nonaktif'),
                      const Spacer(),
                      PopupMenuButton<String>(
                        initialValue: _sortBy,
                        onSelected: (value) {
                          setState(() {
                            _sortBy = value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'harga_tertinggi',
                            child: Text('Harga Tertinggi'),
                          ),
                          const PopupMenuItem(
                            value: 'harga_terendah',
                            child: Text('Harga Terendah'),
                          ),
                          const PopupMenuItem(
                            value: 'nama_a_z',
                            child: Text('Nama A-Z'),
                          ),
                          const PopupMenuItem(
                            value: 'nama_z_a',
                            child: Text('Nama Z-A'),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffDBEAFE),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sort, size: 18),
                              SizedBox(width: 4),
                              Text("Urutkan", style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SellerProductBuilder(
                builder: (context, products) {
                  if (products.isEmpty) {
                    return const Center(child: Text("Belum ada produk"));
                  }

                  var filteredProducts = products.where((product) {
                    if (_searchQuery.isNotEmpty) {
                      final name = product.name.toLowerCase();
                      final category = product.category.toLowerCase();
                      if (!name.contains(_searchQuery) &&
                          !category.contains(_searchQuery)) {
                        return false;
                      }
                    }

                    if (_selectedFilter == 'aktif' && !product.active) {
                      return false;
                    }
                    if (_selectedFilter == 'nonaktif' && product.active) {
                      return false;
                    }

                    if (_selectedCategory.isNotEmpty &&
                        product.category != _selectedCategory) {
                      return false;
                    }

                    return true;
                  }).toList();

                  filteredProducts.sort((a, b) {
                    switch (_sortBy) {
                      case 'harga_tertinggi':
                        return b.price.compareTo(a.price);
                      case 'harga_terendah':
                        return a.price.compareTo(b.price);
                      case 'nama_a_z':
                        return a.name.compareTo(b.name);
                      case 'nama_z_a':
                        return b.name.compareTo(a.name);
                      default:
                        return 0;
                    }
                  });

                  final produkPending = products
                      .where((p) => p.moderationStatus == 'pending')
                      .length;

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProducts.length + (produkPending > 0 ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      if (produkPending > 0 && index == 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.hourglass_empty,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$produkPending produk menunggu review',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final productIndex = produkPending > 0
                          ? index - 1
                          : index;
                      return ProductCard(
                        product: filteredProducts[productIndex],
                        onProductChanged: () {
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String title, bool active, String filterKey) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      child: Container(
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
      ),
    );
  }
}
