import 'package:flutter/foundation.dart';

import '../core/services/product_service_appwrite.dart';
import '../core/services/review_service_appwrite.dart';
import '../data/models/product_model.dart';
import '../data/models/review_model.dart';

class ProductFilterProvider extends ChangeNotifier {
  final ProductServiceAppwrite _service = ProductServiceAppwrite();
  final ReviewServiceAppwrite _reviewService = ReviewServiceAppwrite();

  List<ProductModel> _allProducts = [];
  List<ProductModel> _filteredProducts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _stockFilter = 'Semua';

  List<String> _categories = ['Semua'];

  Map<String, ProductReviewStats> _reviewStats = {};

  String? _cursor;
  bool _hasMore = true;
  static const int _pageSize = 20;

  List<ProductModel> get products => _filteredProducts;
  List<String> get categories => _categories;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get stockFilter => _stockFilter;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  Map<String, ProductReviewStats> get reviewStats => _reviewStats;
  ReviewServiceAppwrite get reviewService => _reviewService;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    _cursor = null;
    _hasMore = true;
    _allProducts = [];
    _filteredProducts = [];
    notifyListeners();

    try {
      final response = await _service.getProductsPage(
        cursor: null,
        limit: _pageSize,
      );
      _allProducts = response.items;
      _cursor = response.nextCursor;
      _hasMore = response.hasMore;
      _extractCategories();
      _applyFilters();
      _loadReviewStats();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _service.getProductsPage(
        cursor: _cursor,
        limit: _pageSize,
      );
      _allProducts.addAll(response.items);
      _cursor = response.nextCursor;
      _hasMore = response.hasMore;
      _extractCategories();
      _applyFilters();
    } catch (_) {
      // silently fail — user can retry by scrolling again
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _loadReviewStats() async {
    try {
      final productIds = _allProducts.map((p) => p.id).toList();
      _reviewStats = await _reviewService.getProductsStats(productIds);
      notifyListeners();
    } catch (_) {
      // silently fail — reviews are optional
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setStockFilter(String filter) {
    _stockFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void _extractCategories() {
    final cats = _allProducts
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    cats.sort();
    _categories = ['Semua', ...cats];
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((p) {
      if (_searchQuery.isNotEmpty &&
          !p.name.toLowerCase().contains(_searchQuery)) {
        return false;
      }
      if (_selectedCategory != 'Semua' && p.category != _selectedCategory) {
        return false;
      }
      if (_stockFilter == 'Tersedia' && p.stock <= 0) return false;
      if (_stockFilter == 'Stok Habis' && p.stock > 0) return false;
      return true;
    }).toList();
  }
}
