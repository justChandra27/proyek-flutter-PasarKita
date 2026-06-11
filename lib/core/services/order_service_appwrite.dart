//lib/core/services/order_service_appwrite.dart

import 'package:appwrite/appwrite.dart';

import '../../data/models/order_model.dart';
import '../../data/models/order_item_model.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';


class OrderServiceAppwrite {
  final Databases databases =
      AppwriteService.databases;

  Future<List<OrderModel>> getOrders() async {
    final result =
        await databases.listDocuments(
      databaseId:
          AppwriteConfig.databaseId,
      collectionId:
          AppwriteConfig.ordersCollectionId,
    );

    return result.documents.map((doc) {
      return OrderModel.fromMap(
        doc.$id,
        doc.data,
      );
    }).toList();
  }

  Future<String> createOrder({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String address,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String notes = '',
  }) async {
    final orderCode = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final totalAmount = items.fold<int>(
      0,
      (sum, item) => sum + (item['subtotal'] as int),
    );
    final now = DateTime.now().toIso8601String();

    final stockBefore = <String, int>{};
    for (final item in items) {
      final productId = item['productId'] as String;
      final quantity = item['quantity'] as int;

      final productDoc = await databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: productId,
      );
      final currentStock = productDoc.data['stock'] as int? ?? 0;

      if (currentStock < quantity) {
        throw AppwriteException(
          'Stok ${item['productName']} tidak mencukupi. '
              'Diminta: $quantity, tersedia: $currentStock',
          400,
          'insufficient_stock',
        );
      }

      stockBefore[productId] = currentStock;
    }

    final order = await databases.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      documentId: ID.unique(),
      data: {
        'orderCode': orderCode,
        'customerId': customerId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'totalAmount': totalAmount,
        'status': 'Pending',
        'paymentMethod': paymentMethod,
        'paymentStatus': 'unpaid',
        'address': address,
        'notes': notes,
        'createdAt': now,
        'updatedAt': now,
      },
    );

    for (final item in items) {
      await databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.orderItemsCollectionId,
        documentId: ID.unique(),
        data: {
          'orderId': order.$id,
          'productId': item['productId'],
          'productName': item['productName'],
          'sellerId': item['sellerId'],
          'price': item['price'],
          'quantity': item['quantity'],
          'subtotal': item['subtotal'],
        },
      );

      final productId = item['productId'] as String;
      final quantity = item['quantity'] as int;
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: productId,
        data: {'stock': stockBefore[productId]! - quantity},
      );
    }

    return order.$id;
  }

  Future<List<OrderModel>> getOrdersByCustomer(
    String customerId,
  ) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      queries: [Query.equal('customerId', customerId)],
    );

    return result.documents.map((doc) {
      return OrderModel.fromMap(doc.$id, doc.data);
    }).toList();
  }

  Future<List<OrderItemModel>> getOrderItems(
    String orderId,
  ) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.orderItemsCollectionId,
      queries: [Query.equal('orderId', orderId)],
    );

    return result.documents.map((doc) {
      return OrderItemModel.fromMap(doc.$id, doc.data);
    }).toList();
  }

  Future<List<OrderItemModel>> getOrdersBySeller(
    String sellerId,
  ) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.orderItemsCollectionId,
      queries: [Query.equal('sellerId', sellerId)],
    );

    return result.documents.map((doc) {
      return OrderItemModel.fromMap(doc.$id, doc.data);
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getSellerOrdersWithDetails(
    String sellerId,
  ) async {
    final allItems = await getOrdersBySeller(sellerId);
    final orderIds = allItems.map((i) => i.orderId).toSet().toList();

    final results = <Map<String, dynamic>>[];
    for (final oid in orderIds) {
      try {
        final doc = await databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.ordersCollectionId,
          documentId: oid,
        );
        final order = OrderModel.fromMap(doc.$id, doc.data);
        final sellerItems =
            allItems.where((i) => i.orderId == oid).toList();
        results.add({
          'order': order,
          'items': sellerItems,
        });
      } catch (_) {
        // skip order if document not found or inaccessible
      }
    }

    results.sort((a, b) => (b['order'] as OrderModel).createdAt
        .compareTo((a['order'] as OrderModel).createdAt));
    return results;
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    await databases.updateDocument(
      databaseId:
          AppwriteConfig.databaseId,
      collectionId:
          AppwriteConfig.ordersCollectionId,
      documentId: orderId,
      data: {
        'status': status,
        'updatedAt':
            DateTime.now()
                .toIso8601String(),
      },
    );
  }
}