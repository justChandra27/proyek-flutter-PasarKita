import 'package:flutter/material.dart';
import '../profile/profile_seller_mobile.dart';

import '../../../core/services/category_service_appwrite.dart';
import '../../../core/services/product_service_appwrite.dart';
import '../../../data/models/category_model.dart';
import '../../../core/appwrite/appwrite_service.dart';
import '../../seller/products/form_produk_seller_mobile.dart' as mobile;

class FormKategoriSellerMobile extends StatefulWidget {
  const FormKategoriSellerMobile({super.key});

  @override
  State<FormKategoriSellerMobile> createState() =>
      _FormKategoriSellerMobileState();
}

class _FormKategoriSellerMobileState extends State<FormKategoriSellerMobile> {
  final _categoryService = CategoryServiceAppwrite();
  final _productService = ProductServiceAppwrite();

  List<CategoryModel> _categories = [];
  Map<String, int> _productCountByCategory = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _categoryService.getAllCategories();
      final account = await AppwriteService.account.get();
      final sellerId = account.$id;
      final products = await _productService.getSellerProducts(sellerId);
      final counts = <String, int>{};
      for (final p in products) {
        if (p.category.isNotEmpty) {
          counts[p.category] = (counts[p.category] ?? 0) + 1;
        }
      }
      if (!mounted) return;
      setState(() {
        _categories = cats;
        _productCountByCategory = counts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  IconData _iconForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('pakaian') || n.contains('fashion') || n.contains('baju')) {
      return Icons.checkroom;
    }
    if (n.contains('elektronik') || n.contains('gadget') || n.contains('komputer')) {
      return Icons.devices;
    }
    if (n.contains('rumah') || n.contains('tangga') || n.contains('dapur') || n.contains('perabot')) {
      return Icons.home;
    }
    if (n.contains('kecantikan') || n.contains('makeup') || n.contains('skincare') || n.contains('beauty')) {
      return Icons.brush;
    }
    if (n.contains('kuliner') || n.contains('makanan') || n.contains('minuman')) {
      return Icons.restaurant;
    }
    if (n.contains('olahraga') || n.contains('sport')) {
      return Icons.sports_basketball;
    }
    if (n.contains('aksesoris') || n.contains('accessories')) {
      return Icons.work;
    }
    return Icons.category;
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
              color: Colors.white,
              padding: const EdgeInsets.all(20),
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
                              builder: (_) =>
                                  const SellerEditProfileMobile(),
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
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kategori Produk",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Kelola inventaris Anda berdasarkan kategori",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Cari kategori...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xffF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _categories.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada kategori",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : GridView(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.95,
                          ),
                          children: [
                            ..._categories.map(
                              (cat) => CategoryCard(
                                icon: _iconForCategory(cat.name),
                                title: cat.name,
                                total: '${_productCountByCategory[cat.name] ?? 0} Produk',
                                onTap: () => _navigateToProductList(cat.name),
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToProductList(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => mobile.FormProdukSellerMobile(initialCategory: category),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String total;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xffEEF2FF),
            child: Icon(icon, color: const Color(0xff2563EB)),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xffDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              total,
              style: const TextStyle(
                color: Color(0xff1E40AF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
