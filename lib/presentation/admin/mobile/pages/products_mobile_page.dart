import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../data/models/product_model.dart';

import 'product_detail_mobile_page.dart';

class _ProductDisplayItem {
  final ProductModel product;
  final String sellerName;

  _ProductDisplayItem({
    required this.product,
    required this.sellerName,
  });
}

class ProductsMobilePage extends StatefulWidget {
  const ProductsMobilePage({super.key});

  @override
  State<ProductsMobilePage> createState() => _ProductsMobilePageState();
}

class _ProductsMobilePageState extends State<ProductsMobilePage> {
  final Databases _db = AppwriteService.databases;
  final TextEditingController _searchController = TextEditingController();

  List<_ProductDisplayItem> _allItems = [];
  List<_ProductDisplayItem> _filteredItems = [];
  bool _loading = true;
  String? _error;
  String _selectedFilter = 'Semua';

  static const _filterOptions = [
    'Semua',
    'Pending',
    'Approved',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        queries: [
          Query.orderDesc('\$createdAt'),
          Query.limit(100),
        ],
      );

      final products = result.documents.map((doc) {
        return ProductModel.fromMap(doc.$id, doc.data);
      }).toList();

      final sellerIds = products
          .map((p) => p.sellerId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final sellerNames = await _batchFetchSellerNames(sellerIds);

      final items = products.map((p) {
        return _ProductDisplayItem(
          product: p,
          sellerName: sellerNames[p.sellerId] ?? 'Unknown Seller',
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _allItems = items;
        _loading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<Map<String, String>> _batchFetchSellerNames(
      List<String> sellerIds) async {
    final map = <String, String>{};
    for (var i = 0; i < sellerIds.length; i += 100) {
      final chunk =
          sellerIds.sublist(i, (i + 100).clamp(0, sellerIds.length));
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('uid', chunk)],
      );
      for (final doc in result.documents) {
        final uid = doc.data['uid'] as String? ?? '';
        map[uid] = (doc.data['storeName'] as String?) ??
            (doc.data['name'] as String?) ??
            'Unknown Seller';
      }
    }
    return map;
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredItems = _allItems.where((item) {
        if (_selectedFilter != 'Semua') {
          if (item.product.moderationStatus.toLowerCase() !=
              _selectedFilter.toLowerCase()) {
            return false;
          }
        }
        if (query.isNotEmpty) {
          final name = item.product.name.toLowerCase();
          final seller = item.sellerName.toLowerCase();
          final category = item.product.category.toLowerCase();
          if (!name.contains(query) &&
              !seller.contains(query) &&
              !category.contains(query)) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  }

  Color _moderationColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _moderationLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String _formatPrice(double price) {
    final p = price.toInt().toString();
    if (p.length > 6) {
      return 'Rp ${(price / 1000000).toStringAsFixed(1)} JT';
    }
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data:\n$_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        const SizedBox(height: 12),
        _buildFilterChips(),
        const SizedBox(height: 12),
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadProducts,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_filteredItems[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari nama produk, seller, kategori...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xffE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xffE5E7EB)),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _filterOptions.map((filter) {
          final selected = _selectedFilter == filter;
          final chipColor = switch (filter) {
            'Pending' => Colors.orange,
            'Approved' => Colors.green,
            'Rejected' => Colors.red,
            _ => const Color(0xff2563EB),
          };
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
                _applyFilters();
              },
              selectedColor: chipColor,
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xff374151),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: selected ? chipColor : const Color(0xffE5E7EB),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductCard(_ProductDisplayItem item) {
    final p = item.product;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailMobilePage(productId: p.id),
            ),
          ).then((_) => _loadProducts());
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: p.imageUrl.isNotEmpty
                  ? Image.network(
                      p.imageUrl,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey.shade100,
                        child: Icon(Icons.image,
                            size: 32, color: Colors.grey.shade400),
                      ),
                    )
                  : Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade100,
                      child: Icon(Icons.image,
                          size: 32, color: Colors.grey.shade400),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xff111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.store_outlined,
                          size: 14, color: Color(0xff6B7280)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.sellerName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xff374151),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(p.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2563EB),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _moderationColor(p.moderationStatus)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _moderationLabel(p.moderationStatus),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _moderationColor(p.moderationStatus),
                      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Belum ada produk',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada produk yang ditemukan.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
