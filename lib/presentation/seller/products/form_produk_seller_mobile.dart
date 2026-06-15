import 'package:flutter/material.dart';

import '../profile/profile_seller_mobile.dart';
import '../../../core/services/category_service_appwrite.dart';
import '../../../data/models/category_model.dart';
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
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = false;

  int get _activeFilterCount {
    int count = 0;
    if (_selectedFilter != 'semua') count++;
    if (_selectedCategory.isNotEmpty) count++;
    return count;
  }

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
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final cats = await CategoryServiceAppwrite().getAllCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
    if (mounted) setState(() => _isLoadingCategories = false);
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
                      const SizedBox(width: 8),
                      Badge(
                        isLabelVisible: _activeFilterCount > 0,
                        label: Text('$_activeFilterCount'),
                        child: GestureDetector(
                          onTap: _showFilterBottomSheet,
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
                                Icon(Icons.filter_list, size: 18),
                                SizedBox(width: 4),
                                Text("Filter", style: TextStyle(fontSize: 13)),
                              ],
                            ),
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Produk',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              const Text(
                'Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Semua', 'Aktif', 'Nonaktif'].map((opt) =>
                  ChoiceChip(
                    label: Text(opt),
                    selected: (_selectedFilter == 'semua' && opt == 'Semua') ||
                        (_selectedFilter == 'aktif' && opt == 'Aktif') ||
                        (_selectedFilter == 'nonaktif' && opt == 'Nonaktif'),
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = opt == 'Semua' ? 'semua' : opt.toLowerCase();
                      });
                      setSheetState(() {});
                    },
                  ),
                ).toList(),
              ),

              const SizedBox(height: 20),

              const Text(
                'Kategori',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              if (_isLoadingCategories)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Semua Kategori'),
                      selected: _selectedCategory.isEmpty,
                      onSelected: (_) {
                        setState(() => _selectedCategory = '');
                        setSheetState(() {});
                      },
                    ),
                    ..._categories.map((cat) => ChoiceChip(
                          label: Text(cat.name),
                          selected: _selectedCategory == cat.name,
                          onSelected: (_) {
                            setState(() => _selectedCategory = cat.name);
                            setSheetState(() {});
                          },
                        )),
                  ],
                ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Terapkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
