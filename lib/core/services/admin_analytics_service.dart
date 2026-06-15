import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
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
  final _withdrawalService = WithdrawalServiceAppwrite();

  Future<AdminAnalytics> getAnalytics() async {
    final results = await Future.wait([
      _fetchOrders(),
      _fetchProductCount(),
      _fetchOrderItems(),
      _fetchUserCounts(),
      _fetchSellerNames(),
      _fetchTotalOrderCount(),
      _fetchCompletedOrderCount(),
      _fetchPendingProductCount(),
      _fetchStatusCounts(),
      _withdrawalService.getPendingWithdrawals(),
    ]);

    final orders = results[0] as List<Map<String, dynamic>>;
    final productCount = results[1] as int;
    final allItems = results[2] as List<Map<String, dynamic>>;
    final userCounts = results[3] as Map<String, int>;
    final sellerNameMap = results[4] as Map<String, String>;
    final totalOrders = results[5] as int;
    final completedOrders = results[6] as int;
    final pendingProducts = results[7] as int;
    final statusCounts = results[8] as Map<String, int>;
    final pendingWithdrawalsList = results[9] as List<dynamic>;

    final totalCustomers = userCounts['customer'] ?? 0;
    final totalSellers = userCounts['seller'] ?? 0;

    final completedOrderIds = <String>{};
    int totalRevenue = 0;
    int totalPlatformRevenue = 0;

    for (final o in orders) {
      final status = (o['status'] as String?)?.toLowerCase() ?? 'pending';
      if (status == 'completed') {
        completedOrderIds.add(o['\$id'] as String);
        totalRevenue += (o['totalAmount'] as num?)?.toInt() ?? 0;
        totalPlatformRevenue +=
            (o['serviceFee'] as num?)?.toInt() ?? 0;
      }
    }

    final pendingWithdrawals = pendingWithdrawalsList.length;
    final pendingWithdrawalAmount = pendingWithdrawalsList.fold<int>(
      0,
      (sum, item) => sum + ((item as dynamic).amount as int? ?? 0),
    );

    final averageOrderValue = completedOrders > 0
        ? totalRevenue ~/ completedOrders
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
      completedOrders: completedOrders,
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

  Future<List<Map<String, dynamic>>> _fetchAllDocs(
    String collectionId, {
    List<String>? baseQueries,
  }) async {
    const pageSize = 5000;
    const maxPages = 100;
    final allDocs = <Map<String, dynamic>>[];
    String? cursorId;
    var pageCount = 0;

    while (true) {
      pageCount++;
      if (pageCount > maxPages) {
        // ignore: avoid_print
        print('WARNING: _fetchAllDocs($collectionId) exceeded $maxPages pages');
        break;
      }

      final queries = <String>[];
      if (baseQueries != null) queries.addAll(baseQueries);
      queries.add(Query.orderAsc('\$id'));
      queries.add(Query.limit(pageSize));
      if (cursorId != null) queries.add(Query.cursorAfter(cursorId));

      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: collectionId,
        queries: queries,
      );

      for (final d in result.documents) {
        allDocs.add(d.data..['\$id'] = d.$id);
      }

      if (result.documents.length < pageSize) break;
      cursorId = result.documents.last.$id;
    }

    return allDocs;
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    return _fetchAllDocs(AppwriteConfig.ordersCollectionId);
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
    return _fetchAllDocs(AppwriteConfig.orderItemsCollectionId);
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
    final docs = await _fetchAllDocs(
      AppwriteConfig.usersCollectionId,
      baseQueries: [Query.equal('role', 'seller')],
    );
    final names = <String, String>{};
    for (final d in docs) {
      final uid = d['uid'] as String?;
      if (uid != null && uid.isNotEmpty) {
        names[uid] =
            (d['storeName'] as String?) ??
            (d['name'] as String?) ??
            'Unknown';
      }
    }
    return names;
  }

  Future<int> _fetchTotalOrderCount() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      queries: [Query.limit(1)],
    );
    return result.total;
  }

  Future<int> _fetchCompletedOrderCount() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      queries: [Query.equal('status', 'completed'), Query.limit(1)],
    );
    return result.total;
  }

  Future<int> _fetchPendingProductCount() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      queries: [Query.equal('moderationStatus', 'pending'), Query.limit(1)],
    );
    return result.total;
  }

  Future<Map<String, int>> _fetchStatusCounts() async {
    final statuses = ['pending', 'processing', 'shipped', 'completed', 'cancelled'];
    final results = await Future.wait(
      statuses.map((s) => _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [Query.equal('status', s), Query.limit(1)],
      )),
    );
    final map = <String, int>{};
    for (var i = 0; i < statuses.length; i++) {
      map[statuses[i]] = results[i].total;
    }
    return map;
  }
}
