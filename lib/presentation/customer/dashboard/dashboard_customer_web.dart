import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/review_service_appwrite.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_filter_provider.dart';
import '../products/detail_produk_customer_web.dart';
import '../widgets/product_card.dart';
import '../widgets/popular_products_row.dart';
import '../widgets/promo_banner.dart';

class DashboardCustomerWeb extends StatefulWidget {
  const DashboardCustomerWeb({super.key});

  @override
  State<DashboardCustomerWeb> createState() =>
      _DashboardCustomerWebState();
}

class _DashboardCustomerWebState
    extends State<DashboardCustomerWeb> {
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
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Column(
          children: [
            const PromoBanner(height: 220, borderRadius: 20),
            const SizedBox(height: 24),
            Consumer<ProductFilterProvider>(
              builder: (context, filter, _) {
                return _searchAndFilterRow(filter);
              },
            ),
            const SizedBox(height: 24),
            Consumer<ProductFilterProvider>(
              builder: (context, filter, _) {
                final popular = List<ProductModel>.from(filter.products)
                  ..sort((a, b) => b.soldCount.compareTo(a.soldCount));
                return PopularProductsRow(
                  products: popular.take(8).toList(),
                  onProductTap: (p) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailProdukCustomerWeb(productId: p.id),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Produk Terbaru",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("Lihat Semua"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Consumer<ProductFilterProvider>(
                builder: (context, filter, _) {
                  if (filter.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (filter.error != null) {
                    return const Center(
                      child: Text(
                        "Gagal memuat produk",
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final products = filter.products;

                  if (products.isEmpty) {
                    return const Center(
                      child: Text("Tidak ada produk yang ditemukan"),
                    );
                  }

                  return Column(
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.75,
                        children: products
                            .map((product) => _productCard(product))
                            .toList(),
                      ),
                      if (filter.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }

  Widget _searchAndFilterRow(ProductFilterProvider filter) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: TextField(
              onChanged: (value) => filter.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: "Cari produk...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xffE2E8F0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Badge(
          isLabelVisible: filter.activeFilterCount > 0,
          label: Text('${filter.activeFilterCount}'),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: filter.activeFilterCount > 0
                  ? const Color(0xff2563EB)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: filter.activeFilterCount > 0
                    ? const Color(0xff2563EB)
                    : Colors.grey.shade300,
              ),
            ),
            child: InkWell(
              onTap: () => _showFilterBottomSheet(filter),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 20,
                    color: filter.activeFilterCount > 0
                        ? Colors.white
                        : Colors.black87,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: filter.activeFilterCount > 0
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(ProductFilterProvider filter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Filter Produk',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        filter.clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- Sort Section ---
                const Text(
                  'Urutkan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Terbaru', 'Nama A-Z', 'Nama Z-A'].map((opt) =>
                    ChoiceChip(
                      label: Text(opt),
                      selected: filter.sortBy == opt,
                      onSelected: (_) {
                        filter.setSortBy(opt);
                        setSheetState(() {});
                      },
                    ),
                  ).toList(),
                ),

                const SizedBox(height: 20),

                // --- Stock Filter Section ---
                const Text(
                  'Filter Stok',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Semua', 'Tersedia', 'Stok Habis'].map((opt) =>
                    ChoiceChip(
                      label: Text(opt),
                      selected: filter.stockFilter == opt,
                      onSelected: (_) {
                        filter.setStockFilter(opt);
                        setSheetState(() {});
                      },
                    ),
                  ).toList(),
                ),

                const SizedBox(height: 20),

                // --- Category Section ---
                const Text(
                  'Kategori',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                const SizedBox(height: 8),
                if (filter.categories.isEmpty)
                  const Text('Tidak ada kategori', style: TextStyle(color: Colors.grey))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: filter.categories.length,
                      itemBuilder: (context, index) {
                        final cat = filter.categories[index];
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(cat),
                          value: filter.selectedCategories.contains(cat),
                          onChanged: (_) {
                            filter.toggleCategory(cat);
                            setSheetState(() {});
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),
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
      ),
    );
  }

  void _showReviews(ProductModel product) async {
    final reviewService = ReviewServiceAppwrite();
    ProductReviewStats stats;
    try {
      stats = await reviewService.getProductStats(product.id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat ulasan: $e')),
      );
      stats = ProductReviewStats.empty();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => _ReviewDialog(
        productName: product.name,
        productId: product.id,
        initialStats: stats,
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    final filter = context.read<ProductFilterProvider>();
    final stats = filter.reviewStats[product.id];
    return ProductCard(
      product: product,
      reviewStats: stats,
      showStockText: false,
      showSoldCount: true,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailProdukCustomerWeb(productId: product.id),
        ),
      ),
      onRatingTap: () => _showReviews(product),
      onAddToCart: () {
        if (product.colors.isNotEmpty || product.sizes.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DetailProdukCustomerWeb(productId: product.id),
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
          duration: const Duration(seconds: 2),
        ));
      },
      buttonBuilder: (outOfStock, onAddToCart) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                outOfStock ? Colors.grey : const Color(0xff2563EB),
          ),
          onPressed: outOfStock ? null : onAddToCart,
          child: Text(
            outOfStock ? 'Stok Habis' : 'Tambah ke Keranjang',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  final String productName;
  final String productId;
  final ProductReviewStats initialStats;

  const _ReviewDialog({
    required this.productName,
    required this.productId,
    required this.initialStats,
  });

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
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
    try {
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _reviews = [];
        _hasMore = false;
      });
    }
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
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 200, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 32),
                const SizedBox(width: 8),
                Text(
                  widget.initialStats.averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${widget.initialStats.reviewCount} ulasan)',
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Ulasan ${widget.productName}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_reviews.isEmpty && !_isLoadingMore)
              const Expanded(
                child: Center(child: Text('Belum ada ulasan')),
              )
            else
              Flexible(
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
                                radius: 18,
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
                                    Text(r.userName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Row(
                                      children: List.generate(5, (j) {
                                        return Icon(
                                          j < r.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatDate(r.createdAt),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          if (r.comment != null &&
                              r.comment!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 44, top: 6),
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
