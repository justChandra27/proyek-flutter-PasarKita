import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/product_service_appwrite.dart';
import '../../../core/services/review_service_appwrite.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../providers/cart_provider.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/product_detail_info.dart';
import '../widgets/product_review_list.dart';

class DetailProdukCustomerWeb extends StatefulWidget {
  final String productId;

  const DetailProdukCustomerWeb({super.key, required this.productId});

  @override
  State<DetailProdukCustomerWeb> createState() =>
      _DetailProdukCustomerWebState();
}

class _DetailProdukCustomerWebState extends State<DetailProdukCustomerWeb> {
  final _productService = ProductServiceAppwrite();
  final _reviewService = ReviewServiceAppwrite();

  ProductModel? _product;
  List<ReviewModel> _reviews = [];
  ProductReviewStats? _stats;
  bool _isLoading = true;
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

  void _addToCart() {
    if (_product == null || _product!.stock <= 0) return;
    context.read<CartProvider>().addItem(CartModel(
      productId: _product!.id,
      sellerId: _product!.sellerId,
      name: _product!.name,
      price: _product!.price.toInt(),
      imageUrl: _product!.imageUrl,
      stock: _product!.stock,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_product!.name} ditambahkan ke keranjang')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? 'Detail Produk'),
        centerTitle: true,
      ),
      body: _buildBody(),
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

    final product = _product!;
    final outOfStock = product.stock <= 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 420,
                  height: 420,
                  child: ProductImageGallery(
                    imageUrl: product.imageUrl,
                    productName: product.name,
                    outOfStock: outOfStock,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProductDetailInfo(
                        product: product,
                        reviewStats: _stats,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: outOfStock ? null : _addToCart,
                                icon: const Icon(Icons.shopping_cart),
                                label: const Text('Tambah ke Keranjang'),
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.bolt),
                                label: const Text('Beli Langsung'),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (outOfStock)
                        const Text(
                          'Produk sedang habis. Silakan cek kembali nanti.',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        )
                      else
                        Text(
                          'Fitur Beli Langsung akan segera hadir.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'Ulasan Pembeli',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ProductReviewList(reviews: _reviews),
          ],
        ),
      ),
    );
  }
}
