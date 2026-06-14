import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import '../../data/models/moderation_status.dart';
import 'product_service_appwrite.dart';
import 'withdrawal_service_appwrite.dart';

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
  final int pendingProducts;
  final int pendingWithdrawals;
  final int pendingWithdrawalAmount;
  final int averageOrderValue;
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
    required this.pendingProducts,
    required this.pendingWithdrawals,
    required this.pendingWithdrawalAmount,
    required this.averageOrderValue,
    required this.orderStatusCounts,
    required this.topSellers,
    required this.topProducts,
  });
}

class AdminAnalyticsService {
  final _db = AppwriteService.databases;
  final _productService = ProductServiceAppwrite();
  final _withdrawalService = WithdrawalServiceAppwrite();

  Future<AdminAnalytics> getAnalytics() async {
    final results = await Future.wait([
      _fetchOrders(),
      _fetchProductCount(),
      _fetchOrderItems(),
      _fetchUserCounts(),
      _fetchSellerNames(),
      _productService.getProductsByStatus(ModerationStatus.pending),
      _withdrawalService.getPendingWithdrawals(),
    ]);

    final orders = results[0] as List<Map<String, dynamic>>;
    final productCount = results[1] as int;
    final allItems = results[2] as List<Map<String, dynamic>>;
    final userCounts = results[3] as Map<String, int>;
    final sellerNameMap = results[4] as Map<String, String>;
    final pendingProductsList = results[5] as List<dynamic>;
    final pendingWithdrawalsList = results[6] as List<dynamic>;

    final totalOrders = orders.length;
    final totalCustomers = userCounts['customer'] ?? 0;
    final totalSellers = userCounts['seller'] ?? 0;

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

    final pendingProducts = pendingProductsList.length;
    final pendingWithdrawals = pendingWithdrawalsList.length;
    final pendingWithdrawalAmount = pendingWithdrawalsList.fold<int>(
      0,
      (sum, item) => sum + ((item as dynamic).amount as int? ?? 0),
    );

    final completedOrdersCount = completedOrderIds.length;
    final averageOrderValue = completedOrdersCount > 0
        ? totalRevenue ~/ completedOrdersCount
        : 0;

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
      completedOrders: completedOrdersCount,
      totalRevenue: totalRevenue,
      totalPlatformRevenue: totalPlatformRevenue,
      pendingProducts: pendingProducts,
      pendingWithdrawals: pendingWithdrawals,
      pendingWithdrawalAmount: pendingWithdrawalAmount,
      averageOrderValue: averageOrderValue,
      orderStatusCounts: statusCounts,
      topSellers: topSellers,
      topProducts: topProducts,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      queries: [Query.limit(100)],
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
      queries: [Query.limit(100)],
    );
    return result.documents.map((d) => d.data..['\$id'] = d.$id).toList();
  }

  Future<Map<String, int>> _fetchUserCounts() async {
    final results = await Future.wait([
      _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('role', 'customer'), Query.limit(1)],
      ),
      _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('role', 'seller'), Query.limit(1)],
      ),
    ]);
    return {
      'customer': results[0].total,
      'seller': results[1].total,
    };
  }

  Future<Map<String, String>> _fetchSellerNames() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.usersCollectionId,
      queries: [Query.equal('role', 'seller'), Query.limit(100)],
    );
    final names = <String, String>{};
    for (final d in result.documents) {
      names[d.$id] = (d.data['name'] as String?) ?? 'Unknown';
    }
    return names;
  }
}
