//lib/core/services/order_service_appwrite.dart

import 'package:appwrite/appwrite.dart';

import '../../data/models/order_model.dart';
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