import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/review_service_appwrite.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/product_filter_provider.dart';

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

  String _formatPrice(double price) {
    final p = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Consumer<ProductFilterProvider>(
              builder: (context, filter, _) {
                return _searchAndFilterRow(filter);
              },
            ),
            const SizedBox(height: 24),
            Consumer<ProductFilterProvider>(
              builder: (context, filter, _) {
                return SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _stockFilterChip(filter),
                      ...filter.categories
                          .map((cat) => _categoryChip(filter, cat)),
                    ],
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
            Expanded(
              child: Consumer<ProductFilterProvider>(
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
                      Expanded(
                        child: GridView.count(
                          controller: _scrollController,
                          crossAxisCount: 4,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.75,
                          children: products
                              .map((product) => _productCard(product))
                              .toList(),
                        ),
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
        PopupMenuButton<String>(
          initialValue: filter.stockFilter,
          onSelected: (v) => filter.setStockFilter(v),
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'Semua', child: Text('Semua')),
            const PopupMenuItem(value: 'Tersedia', child: Text('Tersedia')),
            const PopupMenuItem(value: 'Stok Habis', child: Text('Stok Habis')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 6),
                Text(filter.stockFilter),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _stockFilterChip(ProductFilterProvider filter) {
    return GestureDetector(
      onTap: () {
        final options = ['Semua', 'Tersedia', 'Stok Habis'];
        final idx = options.indexOf(filter.stockFilter);
        filter.setStockFilter(options[(idx + 1) % options.length]);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xff2563EB),
          borderRadius: BorderRadius.circular(30),
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

  Widget _categoryChip(ProductFilterProvider filter, String category) {
    final active = filter.selectedCategory == category;
    return GestureDetector(
      onTap: () => filter.setCategory(active ? 'Semua' : category),
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: active ? const Color(0xffDBEAFE) : Colors.white,
            border: Border.all(
              color: const Color(0xffCBD5E1),
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            category,
            style: TextStyle(
              color: active ? const Color(0xff2563EB) : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _ratingRow(ProductModel product, double avg, int count) {
    if (count == 0) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => _showReviews(product),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 2),
          Text(
            avg.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '($count)',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showReviews(ProductModel product) async {
    final reviewService = ReviewServiceAppwrite();
    final stats = await reviewService.getProductStats(product.id);

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
    final outOfStock = product.stock <= 0;
    final filter = context.read<ProductFilterProvider>();
    final stats = filter.reviewStats[product.id] ??
        ProductReviewStats.empty();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, _, _) => const SizedBox(),
                          ),
                        )
                      : const SizedBox(),
                ),
                if (outOfStock)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Stok Habis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatPrice(product.price),
                  style: const TextStyle(
                    color: Color(0xff2563EB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(outOfStock ? "Stok: Habis" : "Stok: ${product.stock}",
                    style: TextStyle(
                        color: outOfStock ? Colors.red : null)),
                if (stats.reviewCount > 0) ...[
                  const SizedBox(height: 4),
                  _ratingRow(product, stats.averageRating, stats.reviewCount),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: outOfStock
                          ? Colors.grey
                          : const Color(0xff2563EB),
                    ),
                    onPressed: outOfStock
                        ? null
                        : () {
                            context
                                .read<CartProvider>()
                                .addItem(CartModel(
                                  productId: product.id,
                                  sellerId: product.sellerId,
                                  name: product.name,
                                  price: product.price.toInt(),
                                  imageUrl: product.imageUrl,
                                  stock: product.stock,
                                ));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(
                              content: Text(
                                '${product.name} ditambahkan ke keranjang',
                              ),
                              duration: Duration(seconds: 2),
                            ));
                          },
                    child: Text(
                      outOfStock ? "Stok Habis" : "Tambah ke Keranjang",
                      style: const TextStyle(color: Colors.white),
                    ),
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
