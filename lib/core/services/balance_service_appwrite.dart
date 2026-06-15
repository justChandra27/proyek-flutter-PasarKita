import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import '../../data/models/seller_balance_model.dart';
import 'stock_lock_service.dart';

class BalanceServiceAppwrite {
  final Databases _db = AppwriteService.databases;

  Future<SellerBalanceModel?> getBalance(String sellerId) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.sellerBalancesCollectionId,
      queries: [Query.equal('sellerId', sellerId), Query.limit(1)],
    );
    if (result.documents.isEmpty) return null;
    return SellerBalanceModel.fromMap(
      result.documents.first.$id,
      result.documents.first.data,
    );
  }

  Future<SellerBalanceModel> createIfNotExists(String sellerId) async {
    final existing = await getBalance(sellerId);
    if (existing != null) return existing;
    final doc = await _db.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.sellerBalancesCollectionId,
      documentId: ID.unique(),
      data: {
        'sellerId': sellerId,
        'balance': 0,
        'totalEarned': 0,
        'totalWithdrawn': 0,
      },
    );
    return SellerBalanceModel.fromMap(doc.$id, doc.data);
  }

  Future<void> addEarnings(String sellerId, int amount) async {
    final lockService = StockLockService();
    final sessionId = 'earnings-$sellerId-${DateTime.now().microsecondsSinceEpoch}';
    const maxRetries = 3;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        await lockService.acquireLock(
          productId: 'balance:$sellerId',
          sessionId: sessionId,
          ttlSeconds: 5,
        );
      } on AppwriteException catch (_) {
        if (attempt < maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 100 * (attempt + 1)));
          continue;
        }
        rethrow;
      }

      try {
        await createIfNotExists(sellerId);
        final result = await _db.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.sellerBalancesCollectionId,
          queries: [Query.equal('sellerId', sellerId), Query.limit(1)],
        );
        if (result.documents.isEmpty) return;
        final doc = result.documents.first;
        final currentBalance = (doc.data['balance'] as num?)?.toInt() ?? 0;
        final currentEarned = (doc.data['totalEarned'] as num?)?.toInt() ?? 0;
        await _db.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.sellerBalancesCollectionId,
          documentId: doc.$id,
          data: {
            'balance': currentBalance + amount,
            'totalEarned': currentEarned + amount,
          },
        );
        return;
      } finally {
        await lockService.releaseLock(
          productId: 'balance:$sellerId',
          sessionId: sessionId,
        );
      }
    }
  }
}
