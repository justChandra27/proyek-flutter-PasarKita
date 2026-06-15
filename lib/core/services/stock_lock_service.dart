import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';

class StockLockService {
  final Databases _db = AppwriteService.databases;

  Future<void> acquireLock({
    required String productId,
    required String sessionId,
    int ttlSeconds = 30,
  }) async {
    final now = DateTime.now().toUtc();
    final expiresAt = now.add(Duration(seconds: ttlSeconds));

    try {
      await _db.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stockLocksCollectionId,
        documentId: ID.unique(),
        data: {
          'productId': productId,
          'sessionId': sessionId,
          'expiresAt': expiresAt.toIso8601String(),
        },
      );
    } on AppwriteException catch (e) {
      if (e.code == 409) {
        final existing = await _db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.stockLocksCollectionId,
          queries: [Query.equal('productId', productId), Query.limit(1)],
        );
        if (existing.documents.isNotEmpty) {
          final lock = existing.documents.first;
          final expiresAtStr = lock.data['expiresAt'] as String? ?? '';
          final lockExpires = DateTime.tryParse(expiresAtStr) ?? DateTime.now();
          if (lockExpires.isAfter(DateTime.now().toUtc())) {
            throw AppwriteException(
              'Stok sedang diproses untuk produk lain. Coba lagi.',
              409,
              'lock_conflict',
            );
          }
          try {
            await _db.deleteDocument(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.stockLocksCollectionId,
              documentId: lock.$id,
            );
          } catch (_) {
            // expired lock sudah didelete session lain — lanjut
          }
          try {
            await _db.createDocument(
              databaseId: AppwriteConfig.databaseId,
              collectionId: AppwriteConfig.stockLocksCollectionId,
              documentId: ID.unique(),
              data: {
                'productId': productId,
                'sessionId': sessionId,
                'expiresAt': expiresAt.toIso8601String(),
              },
            );
          } on AppwriteException catch (e) {
            if (e.code == 409) {
              throw AppwriteException(
                'Stok sedang diproses untuk produk lain. Coba lagi.',
                409,
                'lock_conflict',
              );
            }
            rethrow;
          }
        }
      } else {
        rethrow;
      }
    }
  }

  Future<void> releaseLock({
    required String productId,
    required String sessionId,
  }) async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stockLocksCollectionId,
        queries: [
          Query.equal('productId', productId),
          Query.equal('sessionId', sessionId),
          Query.limit(1),
        ],
      );
      for (final doc in result.documents) {
        await _db.deleteDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.stockLocksCollectionId,
          documentId: doc.$id,
        );
      }
    } catch (e) {
      // best-effort — TTL akan cleanup
    }
  }

  Future<void> releaseAllLocks(String sessionId) async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stockLocksCollectionId,
        queries: [
          Query.equal('sessionId', sessionId),
          Query.limit(5000),
        ],
      );
      for (final doc in result.documents) {
        try {
          await _db.deleteDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.stockLocksCollectionId,
            documentId: doc.$id,
          );
        } catch (_) {}
      }
    } catch (_) {}
  }
}
