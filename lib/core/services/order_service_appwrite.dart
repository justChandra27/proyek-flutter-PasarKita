//lib/core/services/order_service_appwrite.dart

import 'package:appwrite/appwrite.dart';

import '../../data/models/order_model.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/processing_phase.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import '../constants/fee_config.dart';
import 'balance_service_appwrite.dart';
import 'notification_service_appwrite.dart';
import 'stock_lock_service.dart';


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
    final serviceFee = FeeConfig.serviceFee;
    final itemsSubtotal = items.fold<int>(
      0,
      (sum, item) => sum + (item['subtotal'] as int),
    );
    final totalAmount = itemsSubtotal + serviceFee;
    final now = DateTime.now().toIso8601String();
    final sessionId = 'sess-${DateTime.now().microsecondsSinceEpoch}';
    final lockService = StockLockService();

    // Step 0: aggregate quantities by productId
    final aggregatedQty = <String, int>{};
    for (final item in items) {
      final pid = item['productId'] as String;
      final qty = item['quantity'] as int;
      aggregatedQty[pid] = (aggregatedQty[pid] ?? 0) + qty;
    }
    final uniqueProductIds = aggregatedQty.keys.toList()..sort();
    final stockBefore = <String, int>{};
    final deducted = <String>[];
    final createdItemIds = <String>[];
    String? orderId;
    var phase = ProcessingPhase.none;

    try {
      // Step 1: acquire locks (lock ordering by productId mencegah deadlock)
      for (final pid in uniqueProductIds) {
        await lockService.acquireLock(productId: pid, sessionId: sessionId);
      }
      phase = ProcessingPhase.locked;

      // Step 2: check stock (baca ulang setelah lock — TOCTOU aman)
      for (final pid in uniqueProductIds) {
        final productDoc = await databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollectionId,
          documentId: pid,
        );
        final currentStock = productDoc.data['stock'] as int? ?? 0;
        stockBefore[pid] = currentStock;
        final needed = aggregatedQty[pid]!;
        if (currentStock < needed) {
          throw AppwriteException(
            'Stok tidak mencukupi. Diminta: $needed, tersedia: $currentStock',
            400,
            'insufficient_stock',
          );
        }
      }

      // Step 3: create order
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
          'serviceFee': serviceFee,
          'status': 'pending',
          'paymentMethod': paymentMethod,
          'paymentStatus': 'unpaid',
          'address': address,
          'notes': notes,
          'createdAt': now,
          'updatedAt': now,
        },
      );
      orderId = order.$id;
      phase = ProcessingPhase.orderCreated;

      // Step 4: create order items (preserve individual color/size per item)
      for (final item in items) {
        final subtotal = item['subtotal'] as int;
        final platformFee =
            (subtotal * FeeConfig.platformFeePercent / 100).round();
        final sellerAmount = subtotal - platformFee;

        final itemDoc = await databases.createDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.orderItemsCollectionId,
          documentId: ID.unique(),
          data: {
            'orderId': orderId,
            'productId': item['productId'],
            'productName': item['productName'],
            'sellerId': item['sellerId'],
            'price': item['price'],
            'quantity': item['quantity'],
            'subtotal': subtotal,
            'platformFee': platformFee,
            'sellerAmount': sellerAmount,
            'imageUrl': item['imageUrl'] ?? '',
            'color': item['selectedColor'] ?? '',
            'size': item['selectedSize'] ?? '',
          },
        );
        createdItemIds.add(itemDoc.$id);
      }
      phase = ProcessingPhase.itemsCreated;

      // Step 5: deduct stock (gunakan aggregated quantity per productId)
      for (final pid in uniqueProductIds) {
        final qty = aggregatedQty[pid]!;
        await databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollectionId,
          documentId: pid,
          data: {'stock': stockBefore[pid]! - qty},
        );
        deducted.add(pid);
      }

      // Step 6: release locks (commit)
      try {
        await lockService.releaseAllLocks(sessionId);
      } catch (e) {
        // TTL akan cleanup — data sudah konsisten di DB
      }
      phase = ProcessingPhase.committed;

      return orderId;
    } catch (e) {
      await _rollbackCreateOrder(
        phase: phase,
        sessionId: sessionId,
        orderId: orderId,
        createdItemIds: createdItemIds,
        deducted: deducted,
        stockBefore: stockBefore,
        lockService: lockService,
      );
      rethrow;
    }
  }

  Future<void> _rollbackCreateOrder({
    required ProcessingPhase phase,
    required String sessionId,
    required String? orderId,
    required List<String> createdItemIds,
    required List<String> deducted,
    required Map<String, int> stockBefore,
    required StockLockService lockService,
  }) async {
    switch (phase) {
      case ProcessingPhase.none:
      case ProcessingPhase.locked:
        // Stock belum berubah, order belum dibuat
        // Hanya release partial locks jika ada
        await lockService.releaseAllLocks(sessionId);
        break;

      case ProcessingPhase.orderCreated:
        // Order items mungkin sebagian sudah dibuat, stock belum disentuh
        for (final id in createdItemIds) {
          try {
            await databases.deleteDocument(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.orderItemsCollectionId,
              documentId: id,
            );
          } catch (_) {}
        }
        if (orderId != null) {
          try {
            await databases.deleteDocument(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.ordersCollectionId,
              documentId: orderId,
            );
          } catch (_) {}
        }
        await lockService.releaseAllLocks(sessionId);
        break;

      case ProcessingPhase.itemsCreated:
        // Stock mungkin sudah terdeduct sebagian (partial failure)
        for (final pid in deducted) {
          try {
            await databases.updateDocument(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.productsCollectionId,
              documentId: pid,
              data: {'stock': stockBefore[pid]},
            );
          } catch (_) {}
        }
        for (final id in createdItemIds) {
          try {
            await databases.deleteDocument(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.orderItemsCollectionId,
              documentId: id,
            );
          } catch (_) {}
        }
        if (orderId != null) {
          try {
            await databases.deleteDocument(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.ordersCollectionId,
              documentId: orderId,
            );
          } catch (_) {}
        }
        await lockService.releaseAllLocks(sessionId);
        break;

      case ProcessingPhase.committed:
        // Data sudah konsisten — tidak perlu rollback
        break;
    }
  }

  Future<List<OrderModel>> getOrdersByCustomer(
    String customerId,
  ) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      queries: [
        Query.equal('customerId', customerId),
        Query.orderDesc('\$createdAt'),
      ],
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

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        documentId: orderId,
      );
      return OrderModel.fromMap(doc.$id, doc.data);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? sellerId,
  }) async {
    final current = await getOrderById(orderId);
    if (current == null) {
      throw AppwriteException('Pesanan tidak ditemukan', 404, 'order_not_found');
    }

    final currentStatus = current.status.toLowerCase();
    final newStatus = status.toLowerCase();

    if (sellerId != null) {
      final items = await getOrderItems(orderId);
      final isOwner = items.any((item) => item.sellerId == sellerId);
      if (!isOwner) {
        throw AppwriteException(
          'Anda tidak memiliki akses untuk mengubah pesanan ini',
          403,
          'unauthorized_order_access',
        );
      }
    }

    const allowed = {
      'pending': {'processing', 'cancelled'},
      'processing': {'shipped', 'cancelled'},
      'shipped': {'completed'},
    };

    final allowedNext = allowed[currentStatus];
    if (allowedNext == null || !allowedNext.contains(newStatus)) {
      throw AppwriteException(
        'Transisi status tidak valid: $currentStatus -> $newStatus',
        400,
        'invalid_status_transition',
      );
    }

    await databases.updateDocument(
      databaseId:
          AppwriteConfig.databaseId,
      collectionId:
          AppwriteConfig.ordersCollectionId,
      documentId: orderId,
      data: {
        'status': newStatus,
        'updatedAt':
            DateTime.now()
                .toIso8601String(),
      },
    );

    final notifService = NotificationServiceAppwrite();
    final customerId = current.customerId;
    final orderCode = current.orderCode;

    if (newStatus == 'processing') {
      await notifService.createNotification(
        userId: customerId,
        title: 'Pesanan Diproses',
        message: 'Pesanan #$orderCode sedang diproses oleh penjual.',
        type: 'status_update',
        orderId: orderId,
      );
    } else if (newStatus == 'shipped') {
      await notifService.createNotification(
        userId: customerId,
        title: 'Pesanan Dikirim',
        message: 'Pesanan #$orderCode telah dikirim oleh penjual.',
        type: 'status_update',
        orderId: orderId,
      );
    } else if (newStatus == 'completed') {
      final items = await getOrderItems(orderId);
      for (final item in items) {
        final productDoc = await databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollectionId,
          documentId: item.productId,
        );
        final currentSold = productDoc.data['soldCount'] as int? ?? 0;
        await databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollectionId,
          documentId: item.productId,
          data: {'soldCount': currentSold + item.quantity},
        );
        await BalanceServiceAppwrite().addEarnings(
          item.sellerId,
          item.sellerAmount > 0 ? item.sellerAmount : item.subtotal,
        );
      }
      await notifService.createNotification(
        userId: customerId,
        title: 'Pesanan Selesai',
        message: 'Pesanan #$orderCode telah selesai. Terima kasih telah berbelanja.',
        type: 'status_update',
        orderId: orderId,
      );
    } else if (newStatus == 'cancelled') {
      final items = await getOrderItems(orderId);
      for (final item in items) {
        final productDoc = await databases.getDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollectionId,
          documentId: item.productId,
        );
        final currentStock = productDoc.data['stock'] as int? ?? 0;
        await databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollectionId,
          documentId: item.productId,
          data: {'stock': currentStock + item.quantity},
        );
      }

      await notifService.createNotification(
        userId: customerId,
        title: 'Pesanan Dibatalkan',
        message: 'Pesanan #$orderCode telah dibatalkan.',
        type: 'status_update',
        orderId: orderId,
      );
    }
  }
}