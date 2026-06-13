import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import '../../data/models/seller_balance_model.dart';

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
  }
}
