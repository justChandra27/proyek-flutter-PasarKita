//lib/presentation/admin/categories/form_kategori_web.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';
import '../../../data/models/category_model.dart';

class FormKategoriWeb extends StatefulWidget {
  const FormKategoriWeb({super.key});

  @override
  State<FormKategoriWeb> createState() => _FormKategoriWebState();
}

class _FormKategoriWebState extends State<FormKategoriWeb> {
  final Databases databases = AppwriteService.databases;

  List<CategoryModel> categories = [];
  List<CategoryModel> filteredCategories = [];

  final TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> confirmDeleteCategory(CategoryModel category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Kategori"),
          content: Text("Yakin menghapus kategori ${category.name} ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await deleteCategory(category);
    }
  }

  Future<void> deleteCategory(CategoryModel category) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.categoriesCollectionId,
        documentId: category.documentId,
      );

      await loadCategories();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> showAddCategoryDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Kategori"),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Nama Kategori"),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Deskripsi"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () async {
                await databases.createDocument(
                  databaseId: AppwriteConfig.databaseId,
                  collectionId: AppwriteConfig.categoriesCollectionId,
                  documentId: ID.unique(),
                  data: {
                    "name": nameController.text,
                    "description": descriptionController.text,
                    "productCount": 0,
                    "status": "active",
                  },
                );

                if (!mounted) return;

                Navigator.pop(context);

                await loadCategories();
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> loadCategories() async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.categoriesCollectionId,
      );

      categories = result.documents
          .map((doc) => CategoryModel.fromMap(doc.data, doc.$id))
          .toList();

      setState(() {
        _applyFilter();
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final keyword = searchController.text.toLowerCase();
    filteredCategories = keyword.isEmpty
        ? List.from(categories)
        : categories
            .where((c) => c.name.toLowerCase().contains(keyword))
            .toList();
  }

  void _filterCategories() {
    setState(() {
      _applyFilter();
    });
  }

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
                    "Manajemen Kategori",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => _filterCategories(),
                    decoration: InputDecoration(
                      hintText: "Cari kategori...",
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

                const SizedBox(width: 16),

                Container(width: 1, height: 40, color: Colors.grey.shade300),

                const SizedBox(width: 16),

                const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150"),
                ),

                const SizedBox(width: 10),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Utama",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Super Admin",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Kelola klasifikasi produk Anda untuk memudahkan pencarian oleh pelanggan.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 24),

            // BUTTON
            Row(
              children: [
                const Spacer(),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: showAddCategoryDialog,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Tambah Kategori Baru",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // STAT CARD
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.grid_view_rounded,
                    title: "Total Kategori",
                    value: categories.length.toString(),
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    icon: Icons.inventory_2_outlined,
                    title: "Total Produk",
                    value: "1,248",
                    color: Colors.blueGrey,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    icon: Icons.warning_amber_rounded,
                    title: "Stok Menipis",
                    value: "34",
                    color: Colors.red,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _statCard(
                    icon: Icons.trending_up,
                    title: "Populer (Bulan Ini)",
                    value: categories.isNotEmpty ? categories.first.name : "-",
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      itemCount: filteredCategories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.78,
                          ),
                      itemBuilder: (context, index) {
                        final category = filteredCategories[index];

                        return CategoryCard(
                          title: category.name,
                          productCount: "${category.productCount} Produk",
                          description: category.description,
                          iconData: _categoryIcon(category.name),
                          onDelete: () {
                            confirmDeleteCategory(category);
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

  IconData _categoryIcon(String name) {
    switch (name.toLowerCase()) {
      case 'fashion':
        return Icons.checkroom;
      case 'elektronik':
        return Icons.devices;
      case 'kuliner':
      case 'makanan':
      case 'minuman':
        return Icons.restaurant;
      case 'kecantikan':
        return Icons.face;
      case 'olahraga':
        return Icons.sports_soccer;
      case 'pertanian':
        return Icons.agriculture;
      case 'bayi':
      case 'anak':
      case 'bayi & anak':
        return Icons.child_care;
      case 'otomotif':
        return Icons.directions_car;
      case 'kesehatan':
        return Icons.medical_services;
      case 'buku':
      case 'pendidikan':
        return Icons.menu_book;
      case 'rumah tangga':
        return Icons.chair;
      default:
        return Icons.category;
    }
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
            backgroundColor:
                color.withValues(alpha: .15),
            child: Icon(
              icon,
              color: color,
            ),
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
                  overflow: TextOverflow.ellipsis,
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
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String productCount;
  final String description;
  final IconData iconData;
  final VoidCallback? onDelete;

  const CategoryCard({
    super.key,
    required this.title,
    required this.productCount,
    required this.description,
    this.iconData = Icons.category,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xffF1F5F9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Center(
                  child: Icon(iconData, size: 48, color: const Color(0xff94A3B8)),
                ),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff2563EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    productCount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Icon(Icons.more_vert),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, height: 1.4),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF1F5F9),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Lihat Detail",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

