import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';

class TopSeller {
  final String name;
  final int totalRevenue;
  final int completedOrdersCount;

  TopSeller({
    required this.name,
    required this.totalRevenue,
    required this.completedOrdersCount,
  });
}

class ProductSales {
  final String productName;
  final int totalSold;

  ProductSales({required this.productName, required this.totalSold});
}

class AdminAnalytics {
  final int totalCustomers;
  final int totalSellers;
  final int totalProducts;
  final int totalOrders;
  final int completedOrders;
  final int totalRevenue;
  final int totalPlatformRevenue;
  final Map<String, int> orderStatusCounts;
  final List<TopSeller> topSellers;
  final List<ProductSales> topProducts;

  AdminAnalytics({
    required this.totalCustomers,
    required this.totalSellers,
    required this.totalProducts,
    required this.totalOrders,
    required this.completedOrders,
    required this.totalRevenue,
    required this.totalPlatformRevenue,
    required this.orderStatusCounts,
    required this.topSellers,
    required this.topProducts,
  });
}

class AdminAnalyticsService {
  final _db = AppwriteService.databases;

  Future<AdminAnalytics> getAnalytics() async {
    final results = await Future.wait([
      _fetchOrders(),
      _fetchUsers(),
      _fetchProductCount(),
      _fetchOrderItems(),
    ]);

    final orders = results[0] as List<Map<String, dynamic>>;
    final users = results[1] as List<Map<String, dynamic>>;
    final productCount = results[2] as int;
    final allItems = results[3] as List<Map<String, dynamic>>;

    final totalOrders = orders.length;

    final completedOrderIds = <String>{};
    final statusCounts = <String, int>{};
    int totalRevenue = 0;
    int totalPlatformRevenue = 0;

    for (final o in orders) {
      final status = (o['status'] as String?)?.toLowerCase() ?? 'pending';
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      if (status == 'completed') {
        completedOrderIds.add(o['\$id'] as String);
        totalRevenue += (o['totalAmount'] as num?)?.toInt() ?? 0;
        totalPlatformRevenue +=
            (o['serviceFee'] as num?)?.toInt() ?? 0;
      }
    }

    final totalCustomers =
        users.where((u) => (u['role'] as String?) == 'customer').length;
    final totalSellers =
        users.where((u) => (u['role'] as String?) == 'seller').length;

    final sellerNameMap = <String, String>{};
    for (final u in users) {
      if ((u['role'] as String?) == 'seller') {
        sellerNameMap[u['\$id'] as String] =
            (u['name'] as String?) ?? 'Unknown';
      }
    }

    final sellerRevenue = <String, int>{};
    final sellerOrderCount = <String, int>{};
    final productSales = <String, int>{};

    for (final item in allItems) {
      final orderId = item['orderId'] as String? ?? '';
      if (!completedOrderIds.contains(orderId)) continue;

      final sellerId = item['sellerId'] as String? ?? '';
      final subtotal = (item['subtotal'] as num?)?.toInt() ?? 0;
      final sellerAmount = (item['sellerAmount'] as num?)?.toInt() ?? 0;
      final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
      final productName = item['productName'] as String? ?? '';

      sellerRevenue[sellerId] = (sellerRevenue[sellerId] ?? 0) + (sellerAmount > 0 ? sellerAmount : subtotal);
      sellerOrderCount[sellerId] = (sellerOrderCount[sellerId] ?? 0) + 1;
      productSales[productName] = (productSales[productName] ?? 0) + quantity;
      totalPlatformRevenue +=
          (item['platformFee'] as num?)?.toInt() ?? 0;
    }

    final sortedSellers = sellerRevenue.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSellers = sortedSellers.take(5).map((e) {
      return TopSeller(
        name: sellerNameMap[e.key] ?? 'Unknown',
        totalRevenue: e.value,
        completedOrdersCount: sellerOrderCount[e.key] ?? 0,
      );
    }).toList();

    final sortedProducts = productSales.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topProducts = sortedProducts
        .take(5)
        .map((e) => ProductSales(productName: e.key, totalSold: e.value))
        .toList();

    return AdminAnalytics(
      totalCustomers: totalCustomers,
      totalSellers: totalSellers,
      totalProducts: productCount,
      totalOrders: totalOrders,
      completedOrders: completedOrderIds.length,
      totalRevenue: totalRevenue,
      totalPlatformRevenue: totalPlatformRevenue,
      orderStatusCounts: statusCounts,
      topSellers: topSellers,
      topProducts: topProducts,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
    );
    return result.documents.map((d) => d.data..['\$id'] = d.$id).toList();
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.usersCollectionId,
    );
    return result.documents.map((d) => d.data..['\$id'] = d.$id).toList();
  }

  Future<int> _fetchProductCount() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      queries: [Query.limit(1)],
    );
    return result.total;
  }

  Future<List<Map<String, dynamic>>> _fetchOrderItems() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.orderItemsCollectionId,
    );
    return result.documents.map((d) => d.data..['\$id'] = d.$id).toList();
  }
}
