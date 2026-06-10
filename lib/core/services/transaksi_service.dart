// lib/core/services/transaksi_service.dart

import '../../data/models/transaksi_model.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import 'package:appwrite/appwrite.dart';

class TransaksiService {
  // Gunakan AppwriteService yang sudah ada, tidak perlu buat Client baru
  final _db = AppwriteService.databases;

  // ─── GET SEMUA TRANSAKSI ────────────────────────────────────────────────
  Future<List<TransaksiModel>> getTransaksi({
    String? statusFilter,
    int limit = 10,
    int offset = 0,
    String? searchQuery,
  }) async {
    final queries = <String>[
      Query.limit(limit),
      Query.offset(offset),
      Query.orderDesc('\$createdAt'),
    ];

    if (statusFilter != null && statusFilter.isNotEmpty) {
      queries.add(Query.equal('status', statusFilter));
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      queries.add(Query.search('customer_name', searchQuery));
    }

    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.transaksiCollection,
      queries: queries,
    );

    return result.documents
        .map((doc) => TransaksiModel.fromAppwrite({
              '\$id': doc.$id,
              ...doc.data,
            }))
        .toList();
  }

  // ─── GET TOTAL COUNT ────────────────────────────────────────────────────
  Future<int> getTotalTransaksi({String? statusFilter}) async {
    final queries = <String>[Query.limit(1)];

    if (statusFilter != null && statusFilter.isNotEmpty) {
      queries.add(Query.equal('status', statusFilter));
    }

    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.transaksiCollection,
      queries: queries,
    );

    return result.total;
  }

  // ─── GET STATISTIK ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getStatistik() async {
    final berhasil = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.transaksiCollection,
      queries: [Query.equal('status', 'berhasil'), Query.limit(5000)],
    );

    final pending = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.transaksiCollection,
      queries: [Query.equal('status', 'pending'), Query.limit(1)],
    );

    final gagal = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.transaksiCollection,
      queries: [Query.equal('status', 'gagal'), Query.limit(1)],
    );

    final totalPendapatan = berhasil.documents.fold<int>(
      0,
      (sum, doc) => sum + ((doc.data['jumlah'] ?? 0) as int),
    );

    return {
      'total_pendapatan': totalPendapatan,
      'jumlah_transaksi': berhasil.total + pending.total + gagal.total,
      'transaksi_pending': pending.total,
      'transaksi_gagal': gagal.total,
    };
  }

  // ─── GET SATU TRANSAKSI ─────────────────────────────────────────────────
  Future<TransaksiModel> getTransaksiById(String id) async {
    final doc = await _db.getDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.transaksiCollection,
      documentId: id,
    );

    return TransaksiModel.fromAppwrite({'\$id': doc.$id, ...doc.data});
  }
}