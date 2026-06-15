import 'order_service_appwrite.dart';
import 'product_service_appwrite.dart';
import 'review_service_appwrite.dart';

class ProductSales {
  final String productName;
  final int totalSold;

  ProductSales({required this.productName, required this.totalSold});
}

class SellerAnalytics {
  final int totalProducts;
  final int totalOrders;
  final int completedOrders;
  final int totalRevenue;
  final List<ProductSales> topProducts;
  final Map<String, int> orderStatusCounts;
  final int activeProducts;
  final int pendingReviewProducts;
  final int totalReviews;
  final double averageRating;

  SellerAnalytics({
    required this.totalProducts,
    required this.totalOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.topProducts,
    required this.orderStatusCounts,
    required this.activeProducts,
    required this.pendingReviewProducts,
    required this.totalReviews,
    required this.averageRating,
  });
}

class SellerAnalyticsService {
  final ProductServiceAppwrite _productService = ProductServiceAppwrite();
  final OrderServiceAppwrite _orderService = OrderServiceAppwrite();
  final ReviewServiceAppwrite _reviewService = ReviewServiceAppwrite();

  Future<SellerAnalytics> getAnalytics(String sellerId) async {
    final products = await _productService.getSellerProducts(sellerId);
    final items = await _orderService.getOrdersBySeller(sellerId);

    final orderIds = items.map((i) => i.orderId).toSet().toList();
    final ordersMap = await _orderService.getOrdersByIds(orderIds);
    final orders = ordersMap.values.toList();

    final totalProducts = products.length;
    final activeProducts = products.where((p) => p.active).length;
    final pendingReviewProducts =
        products.where((p) => p.moderationStatus == 'pending').length;
    final totalOrders = orders.length;

    final completedOrderIds = orders
        .where((o) => o.status.toLowerCase() == 'completed')
        .map((o) => o.id)
        .toSet();
    final completedItems =
        items.where((i) => completedOrderIds.contains(i.orderId));
    final completedOrders = completedOrderIds.length;
    final totalRevenue =
        completedItems.fold<int>(0, (sum, i) => sum + (i.sellerAmount > 0 ? i.sellerAmount : i.subtotal));

    final statusCounts = <String, int>{};
    for (final o in orders) {
      final s = o.status.toLowerCase();
      statusCounts[s] = (statusCounts[s] ?? 0) + 1;
    }

    final productSales = <String, int>{};
    for (final i in completedItems) {
      productSales[i.productName] =
          (productSales[i.productName] ?? 0) + i.quantity;
    }
    final sorted = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProducts = sorted
        .take(5)
        .map((e) => ProductSales(productName: e.key, totalSold: e.value))
        .toList();

    int totalReviews = 0;
    double averageRating = 0;
    if (products.isNotEmpty) {
      final productIds = products.map((p) => p.id).toList();
      final statsMap = await _reviewService.getProductsStats(productIds);
      if (statsMap.isNotEmpty) {
        double weightedSum = 0;
        for (final stat in statsMap.values) {
          weightedSum += stat.averageRating * stat.reviewCount;
          totalReviews += stat.reviewCount;
        }
        averageRating = totalReviews > 0 ? weightedSum / totalReviews : 0;
      }
    }

    return SellerAnalytics(
      totalProducts: totalProducts,
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      totalRevenue: totalRevenue,
      topProducts: topProducts,
      orderStatusCounts: statusCounts,
      activeProducts: activeProducts,
      pendingReviewProducts: pendingReviewProducts,
      totalReviews: totalReviews,
      averageRating: averageRating,
    );
  }
}
