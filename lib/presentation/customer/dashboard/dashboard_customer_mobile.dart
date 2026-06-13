import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/review_service_appwrite.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_filter_provider.dart';
import '../products/detail_produk_customer_mobile.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/popular_products_row.dart';
import '../widgets/promo_banner.dart';

class DashboardCustomerMobile extends StatefulWidget {
  const DashboardCustomerMobile({super.key});

  @override
  State<DashboardCustomerMobile> createState() =>
      _DashboardCustomerMobileState();
}

class _DashboardCustomerMobileState
    extends State<DashboardCustomerMobile> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductFilterProvider>().loadProducts();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final filter = context.read<ProductFilterProvider>();
    if (!filter.hasMore || filter.isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      filter.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "PasarKita",
                style: TextStyle(
                  color: Color(0xff2563EB),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const PromoBanner(height: 190, borderRadius: 20),
              const SizedBox(height: 18),
              Consumer<ProductFilterProvider>(
                builder: (context, filter, _) {
                  return _searchBox(filter);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    "Kategori",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Lihat Semua"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<ProductFilterProvider>(
                builder: (context, filter, _) {
                  return SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _stockFilterChip(filter),
                        ...filter.categories.map((cat) => CategoryChip(
                          label: cat,
                          isActive: filter.selectedCategory == cat,
                          onTap: () => filter.setCategory(
                            filter.selectedCategory == cat ? 'Semua' : cat,
                          ),
                          activeBgColor: const Color(0xff2563EB),
                          inactiveBgColor: Colors.white,
                          activeTextColor: Colors.white,
                          inactiveTextColor: Colors.black87,
                          borderColor: Colors.black12,
                          borderRadius: 25,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          activeFontWeight: FontWeight.bold,
                        )),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Consumer<ProductFilterProvider>(
                builder: (context, filter, _) {
                  final popular = List<ProductModel>.from(filter.products)
                    ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
                  return PopularProductsRow(
                    products: popular.take(6).toList(),
                    onProductTap: (p) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailProdukCustomerMobile(productId: p.id),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    "Produk Terbaru",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<ProductFilterProvider>(
                builder: (context, filter, _) {
                  if (filter.isLoading) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (filter.error != null) {
                    return SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          "Gagal memuat produk",
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }

                  final products = filter.products;

                  if (products.isEmpty) {
                    return const SizedBox(
                      height: 200,
                      child: Center(
                        child: Text("Tidak ada produk yang ditemukan"),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.62,
                        children: products
                            .map((product) => _productCard(product))
                            .toList(),
                      ),
                      if (filter.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                          ),
                        )
                      else if (filter.hasMore)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: () => filter.loadMore(),
                              icon: const Icon(Icons.expand_more,
                                  size: 20),
                              label: const Text('Muat lebih banyak'),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBox(ProductFilterProvider filter) {
    return TextField(
      onChanged: (value) => filter.setSearchQuery(value),
      decoration: InputDecoration(
        hintText: "Cari produk...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xffE8EEF9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _stockFilterChip(ProductFilterProvider filter) {
    return GestureDetector(
      onTap: () => _showStockFilter(filter),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xff2563EB),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              filter.stockFilter,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showStockFilter(ProductFilterProvider filter) {
    final options = ['Semua', 'Tersedia', 'Stok Habis'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Stok',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...options.map((opt) => ListTile(
                  title: Text(opt),
                  trailing: filter.stockFilter == opt
                      ? const Icon(Icons.check, color: Color(0xff2563EB))
                      : null,
                  onTap: () {
                    filter.setStockFilter(opt);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showReviews(ProductModel product) async {
    final reviewService = ReviewServiceAppwrite();
    final stats = await reviewService.getProductStats(product.id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReviewBottomSheet(
        productName: product.name,
        productId: product.id,
        initialStats: stats,
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    final filter = context.read<ProductFilterProvider>();
    final stats = filter.reviewStats[product.id] ??
        ProductReviewStats.empty();
    return ProductCard(
      product: product,
      reviewStats: stats,
      showSoldCount: true,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      borderRadius: 20,
      addBorder: true,
      contentPadding: const EdgeInsets.all(12),
      nameFontSize: 18,
      priceFontSize: 16,
      stockInStockColor: Colors.grey,
      crossAxisAlignment: CrossAxisAlignment.start,
      outOfStockPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      outOfStockFontSize: 12,
      outOfStockRadius: 6,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailProdukCustomerMobile(productId: product.id),
        ),
      ),
      onRatingTap: () => _showReviews(product),
      onAddToCart: () {
        if (product.colors.isNotEmpty || product.sizes.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DetailProdukCustomerMobile(productId: product.id),
            ),
          );
          return;
        }
        context.read<CartProvider>().addItem(CartModel(
          productId: product.id,
          sellerId: product.sellerId,
          name: product.name,
          price: product.price.toInt(),
          imageUrl: product.imageUrl,
          stock: product.stock,
        ));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${product.name} ditambahkan ke keranjang'),
        ));
      },
      buttonBuilder: (outOfStock, onAddToCart) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                outOfStock ? Colors.grey : const Color(0xff2563EB),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: outOfStock ? null : onAddToCart,
          icon: const Icon(Icons.shopping_cart, size: 16),
          label: Text(outOfStock ? 'Stok Habis' : 'Tambah ke Keranjang'),
        ),
      ),
    );
  }
}

class _ReviewBottomSheet extends StatefulWidget {
  final String productName;
  final String productId;
  final ProductReviewStats initialStats;

  const _ReviewBottomSheet({
    required this.productName,
    required this.productId,
    required this.initialStats,
  });

  @override
  State<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends State<_ReviewBottomSheet> {
  final ReviewServiceAppwrite _reviewService = ReviewServiceAppwrite();
  final ScrollController _scrollController = ScrollController();

  List<ReviewModel> _reviews = [];
  String? _cursor;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadFirst();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFirst() async {
    final response = await _reviewService.getProductReviewsPage(
      productId: widget.productId,
      cursor: null,
      limit: 10,
    );
    if (!mounted) return;
    setState(() {
      _reviews = response.items;
      _cursor = response.nextCursor;
      _hasMore = response.hasMore;
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final response = await _reviewService.getProductReviewsPage(
        productId: widget.productId,
        cursor: _cursor,
        limit: 10,
      );
      _reviews.addAll(response.items);
      _cursor = response.nextCursor;
      _hasMore = response.hasMore;
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.3,
      expand: false,
      builder: (ctx, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(
                  widget.initialStats.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${widget.initialStats.reviewCount} ulasan)',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ulasan ${widget.productName}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_reviews.isEmpty && !_isLoadingMore)
              const Expanded(
                child: Center(child: Text('Belum ada ulasan')),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _reviews.length +
                      (_hasMore || _isLoadingMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _reviews.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: _isLoadingMore
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : TextButton.icon(
                                  onPressed: _loadMore,
                                  icon: const Icon(Icons.expand_more,
                                      size: 20),
                                  label:
                                      const Text('Muat lebih banyak'),
                                ),
                        ),
                      );
                    }
                    final r = _reviews[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                child: Text(
                                  r.userName.isNotEmpty
                                      ? r.userName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.userName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Row(
                                      children: List.generate(5, (j) {
                                        return Icon(
                                          j < r.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 14,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatDate(r.createdAt),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          if (r.comment != null &&
                              r.comment!.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 40, top: 6),
                              child: Text(r.comment!),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
