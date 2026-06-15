//lib/presentation/seller/categories/form_kategori_seller_web.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../core/services/category_service_appwrite.dart';
import '../../../data/models/category_model.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';

class FormKategoriSellerWeb extends StatefulWidget {
  const FormKategoriSellerWeb({super.key});

  @override
  State<FormKategoriSellerWeb> createState() => _FormKategoriSellerWebState();
}

class _FormKategoriSellerWebState extends State<FormKategoriSellerWeb> {
  final _categoryService = CategoryServiceAppwrite();

  List<CategoryModel> _categories = [];
  bool _loading = true;
  String _sellerName = 'Seller';
  String _initial = 'S';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadCategories();
  }

  Future<void> _loadUser() async {
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

  Future<void> _loadCategories() async {
    try {
      final cats = await _categoryService.getAllCategories();
      if (!mounted) return;
      setState(() {
        _categories = cats;
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
      return Icons.computer;
    }
    if (n.contains('rumah') || n.contains('tangga') || n.contains('dapur') || n.contains('perabot')) {
      return Icons.home;
    }
    if (n.contains('kecantikan') || n.contains('makeup') || n.contains('skincare') || n.contains('beauty')) {
      return Icons.face;
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

  Color _colorForCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('pakaian') || n.contains('fashion')) return Colors.blue;
    if (n.contains('elektronik') || n.contains('gadget')) return Colors.brown;
    if (n.contains('rumah') || n.contains('dapur') || n.contains('perabot')) return Colors.green;
    if (n.contains('kecantikan') || n.contains('beauty')) return Colors.red;
    if (n.contains('kuliner') || n.contains('makanan') || n.contains('minuman')) return Colors.orange;
    if (n.contains('olahraga') || n.contains('sport')) return Colors.teal;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _categories.where((c) => c.status == 'active').length;
    final inactiveCount = _categories.where((c) => c.status != 'active').length;

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
                      decoration: InputDecoration(
                        hintText: "Cari kategori...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Verified Merchant",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
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
                        "Manajemen Kategori",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Atur pengelompokan produk Anda untuk pengalaman belanja yang lebih baik.",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),


              ],
            ),

            const SizedBox(height: 24),

            // STAT CARDS
            if (!_loading)
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      Icons.grid_view_rounded,
                      "Total Kategori",
                      _categories.length.toString(),
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard(
                      Icons.check_circle_outline,
                      "Aktif",
                      activeCount.toString(),
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard(
                      Icons.cancel_outlined,
                      "Nonaktif",
                      inactiveCount.toString(),
                      Colors.red,
                    ),
                  ),
                ],
              ),
            if (!_loading) const SizedBox(height: 24),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _categories.isEmpty
                            ? const Center(
                                child: Text(
                                  "Belum ada kategori",
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 20,
                                      mainAxisSpacing: 20,
                                      childAspectRatio: 1.2,
                                      children: [
                                        ..._categories.map(
                                          (cat) => _categoryCard(
                                            icon: _iconForCategory(cat.name),
                                            iconColor: _colorForCategory(cat.name),
                                            title: cat.name,
                                            description: cat.description,
                                            totalProduct: '${cat.productCount}',
                                            status: cat.status == 'active' ? 'Aktif' : 'Nonaktif',
                                            statusColor: cat.status == 'active' ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                  ),

                  const SizedBox(width: 20),

                  SizedBox(
                    width: 250,
                    child: _tipsCard(),
                  ),
                ],
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
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
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

  Widget _categoryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String totalProduct,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withValues(alpha: .15),
                child: Icon(icon, color: iconColor),
              ),

            ],
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              Text(
                totalProduct,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(width: 5),

              const Text("Produk"),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1D4ED8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tips Optimasi",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          Text(
            "Gunakan nama kategori yang umum dicari pembeli untuk meningkatkan visibilitas produk Anda di hasil pencarian.",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
