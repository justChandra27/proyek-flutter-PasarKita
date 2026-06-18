//lib/core/services/order_service_appwrite.dart

import 'dart:math';

import 'package:appwrite/appwrite.dart';

import '../../data/models/order_model.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/processing_phase.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import '../constants/fee_config.dart';
import 'balance_service_appwrite.dart';
import 'notification_service_appwrite.dart';
import 'receipt_service_appwrite.dart';
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
    String orderCode = '',
    String notes = '',
    String phone = '',
    String shippingAddress = '',
    String shippingCity = '',
    String shippingProvince = '',
    String shippingPostalCode = '',
    String bankName = '',
    String senderName = '',
  }) async {
    final code = orderCode.isNotEmpty
        ? orderCode
        : 'ORD-${DateTime.now().millisecondsSinceEpoch}';
    final serviceFee = FeeConfig.serviceFee;
    final itemsSubtotal = items.fold<int>(
      0,
      (sum, item) => sum + (item['subtotal'] as int),
    );
    final totalAmount = itemsSubtotal + serviceFee;
    final now = DateTime.now().toIso8601String();
    final sessionId = 'sess-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(99999)}';
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
          'orderCode': code,
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
          'phone': phone,
          'shippingAddress': shippingAddress,
          'shippingCity': shippingCity,
          'shippingProvince': shippingProvince,
          'shippingPostalCode': shippingPostalCode,
          'bankName': bankName,
          'senderName': senderName,
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
        Query.limit(5000),
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
      queries: [Query.equal('sellerId', sellerId), Query.limit(5000)],
    );

    return result.documents.map((doc) {
      return OrderItemModel.fromMap(doc.$id, doc.data);
    }).toList();
  }

  Future<Map<String, OrderModel>> getOrdersByIds(
    List<String> orderIds,
  ) async {
    final map = <String, OrderModel>{};
    final unique = orderIds.toSet().toList();
    const chunkSize = 100;
    for (var i = 0; i < unique.length; i += chunkSize) {
      final chunk = unique.sublist(i, (i + chunkSize).clamp(0, unique.length));
      try {
        final result = await databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.ordersCollectionId,
          queries: [
            Query.equal('\$id', chunk),
            Query.limit(chunkSize),
          ],
        );
        for (final doc in result.documents) {
          map[doc.$id] = OrderModel.fromMap(doc.$id, doc.data);
        }
      } catch (_) {}
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> getSellerOrdersWithDetails(
    String sellerId,
  ) async {
    final allItems = await getOrdersBySeller(sellerId);
    final orderIds = allItems.map((i) => i.orderId).toSet().toList();
    final ordersMap = await getOrdersByIds(orderIds);

    final results = <Map<String, dynamic>>[];
    for (final oid in orderIds) {
      final order = ordersMap[oid];
      if (order == null) continue;
      final sellerItems =
          allItems.where((i) => i.orderId == oid).toList();
      results.add({
        'order': order,
        'items': sellerItems,
      });
    }

    results.sort((a, b) => (b['order'] as OrderModel).createdAt
        .compareTo((a['order'] as OrderModel).createdAt));
    return results;
  }

  Future<void> updatePaymentReceipt({
    required String orderId,
    required String receiptFileId,
  }) async {
    await databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      documentId: orderId,
      data: {
        'paymentReceiptImage': receiptFileId,
        'paymentStatus': 'verification',
        'updatedAt': DateTime.now().toIso8601String(),
      },
    );
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

    final notifService = NotificationServiceAppwrite();
    final customerId = current.customerId;
    final orderCode = current.orderCode;

    if (newStatus == 'processing') {
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        documentId: orderId,
        data: {
          'status': newStatus,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      await notifService.createNotification(
        userId: customerId,
        title: 'Pesanan Diproses',
        message: 'Pesanan #$orderCode sedang diproses oleh penjual.',
        type: 'status_update',
        orderId: orderId,
      );
    } else if (newStatus == 'shipped') {
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        documentId: orderId,
        data: {
          'status': newStatus,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      await notifService.createNotification(
        userId: customerId,
        title: 'Pesanan Dikirim',
        message: 'Pesanan #$orderCode telah dikirim oleh penjual.',
        type: 'status_update',
        orderId: orderId,
      );
    } else if (newStatus == 'completed') {
      final lockService = StockLockService();
      final sessionId = 'complete-$orderId-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(99999)}';

      await lockService.acquireLock(
        productId: 'order:$orderId',
        sessionId: sessionId,
        ttlSeconds: 10,
      );
      try {
        final recheck = await getOrderById(orderId);
        if (recheck == null || recheck.status.toLowerCase() != 'shipped') {
          throw AppwriteException('Pesanan sudah diproses', 400, 'invalid_status_transition');
        }

        await databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.ordersCollectionId,
          documentId: orderId,
          data: {
            'status': newStatus,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );

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
        }

        await notifService.createNotification(
          userId: customerId,
          title: 'Pesanan Selesai',
          message: 'Pesanan #$orderCode telah selesai. Terima kasih telah berbelanja.',
          type: 'status_update',
          orderId: orderId,
        );
      } finally {
        await lockService.releaseLock(
          productId: 'order:$orderId',
          sessionId: sessionId,
        );
      }
    } else if (newStatus == 'cancelled') {
      final lockService = StockLockService();
      final sessionId = 'cancel-$orderId-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(99999)}';

      await lockService.acquireLock(
        productId: 'order:$orderId',
        sessionId: sessionId,
        ttlSeconds: 10,
      );
      try {
        final recheck = await getOrderById(orderId);
        if (recheck == null || !{'pending', 'processing'}.contains(recheck.status.toLowerCase())) {
          throw AppwriteException('Pesanan sudah diproses', 400, 'invalid_status_transition');
        }

        await databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.ordersCollectionId,
          documentId: orderId,
          data: {
            'status': newStatus,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );

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
      } finally {
        await lockService.releaseLock(
          productId: 'order:$orderId',
          sessionId: sessionId,
        );
      }
    }
  }

  Future<void> approvePayment(String orderId) async {
    final order = await getOrderById(orderId);
    if (order == null) {
      throw AppwriteException('Pesanan tidak ditemukan', 404, 'order_not_found');
    }
    if (order.paymentStatus == 'paid') {
      throw AppwriteException(
        'Pembayaran sudah disetujui sebelumnya',
        400,
        'payment_already_paid',
      );
    }
    if (order.paymentStatus != 'verification') {
      throw AppwriteException(
        'Status pembayaran bukan verification',
        400,
        'invalid_payment_status',
      );
    }
    final now = DateTime.now().toIso8601String();
    final user = await AppwriteService.account.get();
    await databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      documentId: orderId,
      data: {
        'paymentStatus': 'paid',
        'paymentConfirmedAt': now,
        'paymentConfirmedBy': user.$id,
        'updatedAt': now,
      },
    );
    final items = await getOrderItems(orderId);
    for (final item in items) {
      final amount = item.sellerAmount > 0 ? item.sellerAmount : item.subtotal;
      await BalanceServiceAppwrite().addEarnings(item.sellerId, amount);
    }

    try {
      await ReceiptServiceAppwrite().generateAndUploadReceipt(
        order: order,
        items: items,
      );
    } catch (e) {
      // Jangan rollback paymentStatus — tetap paid
    }
  }

  Future<void> rejectPayment(String orderId) async {
    final now = DateTime.now().toIso8601String();
    final user = await AppwriteService.account.get();
    await databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      documentId: orderId,
      data: {
        'paymentStatus': 'rejected',
        'paymentConfirmedAt': now,
        'paymentConfirmedBy': user.$id,
        'updatedAt': now,
      },
    );
  }
}

class AdminOrdersPage {
  final List<OrderModel> orders;
  final int total;

  AdminOrdersPage({required this.orders, required this.total});
}

extension OrderServiceAdmin on OrderServiceAppwrite {
  Future<Map<String, int>> getOrderStatistics() async {
    final results = await Future.wait([
      databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [Query.limit(1)],
      ),
      databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [Query.equal('status', 'pending'), Query.limit(1)],
      ),
      databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [Query.equal('status', 'processing'), Query.limit(1)],
      ),
      databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [Query.equal('status', 'shipped'), Query.limit(1)],
      ),
      databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [Query.equal('status', 'completed'), Query.limit(1)],
      ),
      databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        queries: [Query.equal('status', 'cancelled'), Query.limit(1)],
      ),
    ]);

    return {
      'total': results[0].total,
      'pending': results[1].total,
      'processing': results[2].total,
      'shipped': results[3].total,
      'completed': results[4].total,
      'cancelled': results[5].total,
    };
  }

  Future<AdminOrdersPage> getAdminOrdersPage({
    int limit = 25,
    String? cursor,
    String? status,
    String? search,
  }) async {
    final queries = <String>[];
    if (status != null && status.isNotEmpty) {
      queries.add(Query.equal('status', status));
    }
    if (search != null && search.isNotEmpty) {
      queries.add(Query.contains('orderCode', search));
    }
    if (cursor != null && cursor.isNotEmpty) {
      queries.add(Query.cursorAfter(cursor));
    }
    queries.add(Query.limit(limit.clamp(1, 100)));
    queries.add(Query.orderDesc('\$createdAt'));

    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      queries: queries,
    );

    final orders = result.documents.map((doc) {
      return OrderModel.fromMap(doc.$id, doc.data);
    }).toList();

    return AdminOrdersPage(orders: orders, total: result.total);
  }
}