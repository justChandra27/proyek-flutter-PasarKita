import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import '../../data/models/withdrawal_model.dart';
import 'balance_service_appwrite.dart';

class WithdrawalServiceAppwrite {
  final Databases _db = AppwriteService.databases;
  final BalanceServiceAppwrite _balanceService = BalanceServiceAppwrite();

  Future<WithdrawalModel> requestWithdrawal({
    required String sellerId,
    required int amount,
    required String bankName,
    required String bankAccount,
    required String accountName,
  }) async {
    final balance = await _balanceService.getBalance(sellerId);
    final currentBalance = balance?.balance ?? 0;
    if (currentBalance < amount) {
      throw Exception('Saldo tidak mencukupi');
    }

    final now = DateTime.now().toIso8601String();
    final doc = await _db.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.withdrawalsCollectionId,
      documentId: ID.unique(),
      data: {
        'sellerId': sellerId,
        'amount': amount,
        'bankName': bankName,
        'bankAccount': bankAccount,
        'accountName': accountName,
        'status': 'pending',
        'adminNote': '',
        'requestedAt': now,
        'processed_at': '',
        'processed_by': '',
      },
    );
    return WithdrawalModel.fromMap(doc.$id, doc.data);
  }

  Future<List<WithdrawalModel>> getHistory(String sellerId) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.withdrawalsCollectionId,
      queries: [
        Query.equal('sellerId', sellerId),
        Query.orderDesc('\$createdAt'),
      ],
    );
    return result.documents
        .map((doc) => WithdrawalModel.fromMap(doc.$id, doc.data))
        .toList();
  }

  Future<List<WithdrawalModel>> getPendingWithdrawals() async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.withdrawalsCollectionId,
      queries: [
        Query.equal('status', 'pending'),
        Query.orderDesc('\$createdAt'),
      ],
    );
    return result.documents
        .map((doc) => WithdrawalModel.fromMap(doc.$id, doc.data))
        .toList();
  }

  Future<void> approveWithdrawal(
    String withdrawalId,
    String adminId,
  ) async {
    final doc = await _db.getDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.withdrawalsCollectionId,
      documentId: withdrawalId,
    );
    final status = doc.data['status'] as String? ?? '';
    if (status != 'pending') {
      throw Exception('Withdrawal sudah diproses');
    }

    final sellerId = doc.data['sellerId'] as String? ?? '';
    final amount = (doc.data['amount'] as num?)?.toInt() ?? 0;

    final balance = await _balanceService.getBalance(sellerId);
    final currentBalance = balance?.balance ?? 0;
    if (currentBalance < amount) {
      throw Exception('Saldo seller tidak mencukupi');
    }

    await _balanceService.createIfNotExists(sellerId);
    final balResult = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.sellerBalancesCollectionId,
      queries: [Query.equal('sellerId', sellerId), Query.limit(1)],
    );
    if (balResult.documents.isNotEmpty) {
      final balDoc = balResult.documents.first;
      final curBalance = (balDoc.data['balance'] as num?)?.toInt() ?? 0;
      final curWithdrawn = (balDoc.data['totalWithdrawn'] as num?)?.toInt() ?? 0;
      await _db.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.sellerBalancesCollectionId,
        documentId: balDoc.$id,
        data: {
          'balance': curBalance - amount,
          'totalWithdrawn': curWithdrawn + amount,
        },
      );
    }

    final now = DateTime.now().toIso8601String();
    await _db.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.withdrawalsCollectionId,
      documentId: withdrawalId,
      data: {
        'status': 'approved',
        'processed_at': now,
        'processed_by': adminId,
      },
    );
  }

  Future<void> rejectWithdrawal({
    required String withdrawalId,
    required String adminId,
    required String note,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _db.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.withdrawalsCollectionId,
      documentId: withdrawalId,
      data: {
        'status': 'rejected',
        'adminNote': note,
        'processed_at': now,
        'processed_by': adminId,
      },
    );
  }
}
