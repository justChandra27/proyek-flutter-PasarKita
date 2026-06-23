import 'dart:math';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';

import '../../data/models/return_model.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import 'balance_service_appwrite.dart';
import 'notification_service_appwrite.dart';
import 'order_service_appwrite.dart';
import 'stock_lock_service.dart';
import 'storage_service_appwrite.dart';

class ReturnServiceAppwrite {
  final Databases databases = AppwriteService.databases;

  static const Map<String, Set<String>> _allowedTransitions = {
    'requested': {'approved', 'rejected'},
  };

  Future<ReturnModel> createReturn({
    required String orderId,
    required String orderItemId,
    required String customerId,
    required String sellerId,
    required String reason,
    required String description,
    required List<Uint8List> photoBytes,
    required String orderCode,
  }) async {
    // AUDIT 5: Verify customer owns this order
    final order = await OrderServiceAppwrite().getOrderById(orderId);
    if (order == null) {
      throw AppwriteException('Pesanan tidak ditemukan', 404, 'order_not_found');
    }
    if (order.customerId != customerId) {
      throw AppwriteException(
        'Anda tidak memiliki akses ke pesanan ini',
        403,
        'unauthorized_order_access',
      );
    }
    if (order.status.toLowerCase() != 'completed') {
      throw AppwriteException(
        'Retur hanya dapat diajukan untuk pesanan selesai',
        400,
        'order_not_completed',
      );
    }

    // AUDIT 1: Duplicate check in service (not only UI)
    final existing = await hasReturnByOrderItem(orderItemId);
    if (existing) {
      throw AppwriteException(
        'Retur untuk item ini sudah pernah diajukan',
        400,
        'duplicate_return',
      );
    }

    final storage = StorageServiceAppwrite();
    final photoUrls = <String>[];
    for (int i = 0; i < photoBytes.length; i++) {
      final fileId = await storage.uploadImage(
        bytes: photoBytes[i],
        fileName: 'return_${orderCode}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
      );
      photoUrls.add(fileId);
    }

    // AUDIT 6: Set return deadline (30 days from now)
    final deadline = DateTime.now().add(const Duration(days: 30));
    final returnDeadline = deadline.toIso8601String();

    final doc = await databases.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.returnsCollectionId,
      documentId: ID.unique(),
      data: {
        'orderId': orderId,
        'orderItemId': orderItemId,
        'customerId': customerId,
        'sellerId': sellerId,
        'reason': reason,
        'description': description,
        'photoUrls': photoUrls,
        'status': 'requested',
        'orderCode': orderCode,
        'refundAmount': 0,
        'processedBy': '',
        'returnDeadline': returnDeadline,
        'adminNote': '',
        'approvedAt': '',
        'rejectedAt': '',
      },
    );

    // AUDIT 7: Notification after successful DB write
    final notifService = NotificationServiceAppwrite();
    await notifService.createNotification(
      userId: sellerId,
      title: 'Pengajuan Retur',
      message: 'Customer mengajukan retur untuk pesanan $orderCode.',
      type: 'return_requested',
      orderId: orderId,
    );

    return ReturnModel.fromMap(doc.$id, doc.data);
  }

  Future<List<ReturnModel>> getReturnsByCustomer(String customerId) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.returnsCollectionId,
      queries: [
        Query.equal('customerId', customerId),
        Query.orderDesc('\$createdAt'),
        Query.limit(100),
      ],
    );

    return result.documents
        .map((doc) => ReturnModel.fromMap(doc.$id, doc.data))
        .toList();
  }

  Future<List<ReturnModel>> getReturnsBySeller(String sellerId) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.returnsCollectionId,
      queries: [
        Query.equal('sellerId', sellerId),
        Query.orderDesc('\$createdAt'),
        Query.limit(100),
      ],
    );

    return result.documents
        .map((doc) => ReturnModel.fromMap(doc.$id, doc.data))
        .toList();
  }

  Future<ReturnModel?> getReturnById(String returnId) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.returnsCollectionId,
        documentId: returnId,
      );
      return ReturnModel.fromMap(doc.$id, doc.data);
    } on AppwriteException catch (_) {
      return null;
    }
  }

  Future<bool> hasReturnByOrderItem(String orderItemId) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.returnsCollectionId,
      queries: [
        Query.equal('orderItemId', orderItemId),
        Query.limit(1),
      ],
    );
    return result.documents.isNotEmpty;
  }

  Future<bool> hasReturnByProductAndOrder({
    required String orderId,
    required String productId,
  }) async {
    final orderService = OrderServiceAppwrite();
    final items = await orderService.getOrderItems(orderId);
    final matchingItem = items.where((i) => i.productId == productId).firstOrNull;
    if (matchingItem == null) return false;
    return hasReturnByOrderItem(matchingItem.id);
  }

  Future<void> _validateTransition(String returnId, String newStatus) async {
    final returnData = await getReturnById(returnId);
    if (returnData == null) {
      throw AppwriteException('Retur tidak ditemukan', 404, 'return_not_found');
    }

    final currentStatus = returnData.status;
    final allowed = _allowedTransitions[currentStatus];

    if (allowed == null || !allowed.contains(newStatus)) {
      throw AppwriteException(
        'Transisi status tidak valid: $currentStatus → $newStatus',
        400,
        'invalid_return_status_transition',
      );
    }

    // AUDIT 6: Check return deadline
    if (returnData.returnDeadline.isNotEmpty) {
      final deadline = DateTime.tryParse(returnData.returnDeadline);
      if (deadline != null && DateTime.now().isAfter(deadline)) {
        throw AppwriteException(
          'Batas waktu retur telah berakhir',
          400,
          'return_deadline_expired',
        );
      }
    }
  }

  Future<void> approveReturn(String returnId, String processedBy) async {
    // AUDIT 2 & 3: Validate transition + double-click protection
    await _validateTransition(returnId, 'approved');

    // AUDIT 4: Seller authorization
    final returnData = await getReturnById(returnId);
    if (returnData == null) {
      throw AppwriteException('Retur tidak ditemukan', 404, 'return_not_found');
    }
    if (returnData.sellerId != processedBy) {
      throw AppwriteException(
        'Anda tidak memiliki akses ke retur ini',
        403,
        'unauthorized_return_access',
      );
    }

    final orderService = OrderServiceAppwrite();
    final items = await orderService.getOrderItems(returnData.orderId);
    final item = items.where((i) => i.id == returnData.orderItemId).firstOrNull;
    if (item == null) {
      throw AppwriteException('Item pesanan tidak ditemukan', 404, 'order_item_not_found');
    }

    final amount = item.sellerAmount > 0 ? item.sellerAmount : item.subtotal;
    await BalanceServiceAppwrite().deductEarnings(returnData.sellerId, amount);

    await databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.returnsCollectionId,
      documentId: returnId,
      data: {
        'status': 'approved',
        'processedBy': processedBy,
        'approvedAt': DateTime.now().toIso8601String(),
        'refundAmount': amount,
      },
    );

    // AUDIT 7: Notification after successful DB update
    final updated = await getReturnById(returnId);
    if (updated != null) {
      final notifService = NotificationServiceAppwrite();
      await notifService.createNotification(
        userId: updated.customerId,
        title: 'Retur Disetujui',
        message: 'Retur pesanan ${updated.orderCode} disetujui.',
        type: 'return_approved',
        orderId: updated.orderId,
      );
    }
  }

  Future<void> rejectReturn(
      String returnId, String processedBy, String adminNote) async {
    // AUDIT 2 & 3: Validate transition + double-click protection
    await _validateTransition(returnId, 'rejected');

    // AUDIT 4: Seller authorization
    final returnData = await getReturnById(returnId);
    if (returnData == null) {
      throw AppwriteException('Retur tidak ditemukan', 404, 'return_not_found');
    }
    if (returnData.sellerId != processedBy) {
      throw AppwriteException(
        'Anda tidak memiliki akses ke retur ini',
        403,
        'unauthorized_return_access',
      );
    }

    await databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.returnsCollectionId,
      documentId: returnId,
      data: {
        'status': 'rejected',
        'processedBy': processedBy,
        'rejectedAt': DateTime.now().toIso8601String(),
        'adminNote': adminNote,
      },
    );

    // AUDIT 7: Notification after successful DB update
    final updated = await getReturnById(returnId);
    if (updated != null) {
      final notifService = NotificationServiceAppwrite();
      await notifService.createNotification(
        userId: updated.customerId,
        title: 'Retur Ditolak',
        message:
            'Retur pesanan ${updated.orderCode} ditolak. Alasan: $adminNote',
        type: 'return_rejected',
        orderId: updated.orderId,
      );
    }
  }

  Future<void> markReceived(String returnId) async {
    await _validateTransition(returnId, 'received');
    await databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.returnsCollectionId,
      documentId: returnId,
      data: {
        'status': 'received',
      },
    );
  }

  Future<void> markRefunded(String returnId) async {
    final returnData = await getReturnById(returnId);
    if (returnData == null) {
      throw AppwriteException('Retur tidak ditemukan', 404, 'return_not_found');
    }
    if (returnData.refundAmount > 0) {
      throw AppwriteException(
        'Refund sudah diproses',
        400,
        'refund_already_processed',
      );
    }

    final lockService = StockLockService();
    final sessionId = 'refund-$returnId-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(99999)}';
    await lockService.acquireLock(
      productId: 'return:refund:$returnId',
      sessionId: sessionId,
      ttlSeconds: 10,
    );
    try {
      await _validateTransition(returnId, 'refunded');

      final orderService = OrderServiceAppwrite();
      final items = await orderService.getOrderItems(returnData.orderId);
      final item = items.where((i) => i.id == returnData.orderItemId).firstOrNull;
      if (item == null) {
        throw AppwriteException('Item pesanan tidak ditemukan', 404, 'order_item_not_found');
      }

      final amount = item.sellerAmount > 0 ? item.sellerAmount : item.subtotal;
      await BalanceServiceAppwrite().deductEarnings(item.sellerId, amount);

      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.returnsCollectionId,
        documentId: returnId,
        data: {
          'status': 'refunded',
          'refundAmount': amount,
        },
      );

      await NotificationServiceAppwrite().createNotification(
        userId: returnData.customerId,
        title: 'Refund Retur',
        message: 'Refund untuk retur pesanan ${returnData.orderCode} telah diproses.',
        type: 'return_refunded',
        orderId: returnData.orderId,
      );
    } finally {
      await lockService.releaseLock(
        productId: 'return:refund:$returnId',
        sessionId: sessionId,
      );
    }
  }
}
