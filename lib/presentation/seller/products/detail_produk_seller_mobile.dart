import 'package:flutter/material.dart';

import '../../../core/services/product_service_appwrite.dart';
import '../../../core/services/review_service_appwrite.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/moderation_status.dart';
import '../../customer/widgets/product_image_gallery.dart';
import '../../customer/widgets/product_detail_info.dart';
import '../../customer/widgets/product_review_list.dart';
import 'widgets/moderation_status_badge.dart';
import 'product_form_page.dart';

class DetailProdukSellerMobile extends StatefulWidget {
  final String productId;

  const DetailProdukSellerMobile({super.key, required this.productId});

  @override
  State<DetailProdukSellerMobile> createState() =>
      _DetailProdukSellerMobileState();
}

class _DetailProdukSellerMobileState extends State<DetailProdukSellerMobile> {
  final _productService = ProductServiceAppwrite();
  final _reviewService = ReviewServiceAppwrite();

  ProductModel? _product;
  List<ReviewModel> _reviews = [];
  ProductReviewStats? _stats;
  bool _isLoading = true;
  bool _isInactive = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final product = await _productService.getProductById(widget.productId);
      if (product == null) {
        if (mounted) {
          setState(() {
            _error = 'Produk tidak ditemukan';
            _isLoading = false;
          });
        }
        return;
      }

      if (!product.active) {
        if (mounted) {
          setState(() {
            _product = product;
            _isInactive = true;
            _isLoading = false;
          });
        }
        return;
      }

      final results = await Future.wait([
        _reviewService.getProductReviews(product.id),
        _reviewService.getProductStats(product.id),
      ]);

      if (mounted) {
        setState(() {
          _product = product;
          _reviews = results[0] as List<ReviewModel>;
          _stats = results[1] as ProductReviewStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Gagal memuat data: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToEdit() async {
    if (_product == null) return;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(product: _product),
      ),
    );
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _toggleActive() async {
    if (_product == null) return;
    try {
      await _productService.updateProduct(
        productId: _product!.id,
        name: _product!.name,
        category: _product!.category,
        description: _product!.description,
        price: _product!.price,
        stock: _product!.stock,
        imageUrl: _product!.imageUrl,
        active: !_product!.active,
        weight: _product!.weight,
        minPurchase: _product!.minPurchase,
        colors: _product!.colors,
        sizes: _product!.sizes,
        moderationNote: _product!.moderationNote,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _product!.active ? 'Produk dinonaktifkan' : 'Produk diaktifkan',
            ),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? 'Detail Produk'),
        centerTitle: true,
      ),
      body: _buildBody(),
      bottomNavigationBar: _product != null && !_isLoading && !_isInactive
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    if (_isInactive) {
      final note = _product!.moderationNote;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Produk Tidak Aktif',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (note.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(note,
                            style: TextStyle(color: Colors.orange.shade900)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _toggleActive,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Aktifkan Produk'),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: ProductImageGallery(
              imageUrl: product.imageUrl,
              productName: product.name,
              outOfStock: product.stock <= 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductDetailInfo(product: product, reviewStats: _stats),
                const SizedBox(height: 16),
                const Text('Status Moderasi',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ModerationStatusBadge(
                  status: ModerationStatus.fromJson(product.moderationStatus),
                ),
                if (product.colors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Warna',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: product.colors.map((color) {
                      return Chip(
                        label: Text(color, style: const TextStyle(fontSize: 13)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
                if (product.sizes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text('Ukuran',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: product.sizes.map((size) {
                      return Chip(
                        label: Text(size, style: const TextStyle(fontSize: 13)),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'Ulasan Pembeli',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ProductReviewList(reviews: _reviews),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final product = _product!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _navigateToEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Produk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _toggleActive,
                icon: Icon(
                  product.active
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                label: Text(
                  product.active ? 'Nonaktifkan' : 'Aktifkan',
                  style: const TextStyle(fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: product.active ? Colors.red : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
