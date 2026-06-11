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