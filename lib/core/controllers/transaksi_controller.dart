//lib/core/controllers/transaksi_controller.dart

import 'package:flutter/material.dart';

import '../../data/models/transaksi_model.dart';
import '../services/transaksi_service.dart';
class TransaksiController extends ChangeNotifier {
  final TransaksiService _service = TransaksiService();

  // ─── STATE ────────────────────────────────────────────────────────────────
  List<TransaksiModel> transaksiList = [];
  bool isLoading = false;
  String? errorMessage;

  // Statistik
  int totalPendapatan = 0;
  int jumlahTransaksi = 0;
  int transaksiPending = 0;
  int transaksiGagal = 0;

  // Pagination
  int currentPage = 1;
  int totalData = 0;
  final int perPage = 10;
  int get totalPages => (totalData / perPage).ceil();

  // Filter
  String? statusFilter;
  String searchQuery = '';

  // ─── INIT ─────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await Future.wait([
      loadTransaksi(),
      loadStatistik(),
    ]);
  }

  // ─── LOAD TRANSAKSI ───────────────────────────────────────────────────────
  Future<void> loadTransaksi() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final offset = (currentPage - 1) * perPage;

      final results = await _service.getTransaksi(
        statusFilter: statusFilter,
        limit: perPage,
        offset: offset,
        searchQuery: searchQuery.isEmpty ? null : searchQuery,
      );

      totalData = await _service.getTotalTransaksi(
        statusFilter: statusFilter,
      );

      transaksiList = results;
    } catch (e) {
      errorMessage = 'Gagal memuat transaksi: ${e.toString()}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ─── LOAD STATISTIK ───────────────────────────────────────────────────────
  Future<void> loadStatistik() async {
    try {
      final stats = await _service.getStatistik();
      totalPendapatan = stats['total_pendapatan'] ?? 0;
      jumlahTransaksi = stats['jumlah_transaksi'] ?? 0;
      transaksiPending = stats['transaksi_pending'] ?? 0;
      transaksiGagal = stats['transaksi_gagal'] ?? 0;
      notifyListeners();
    } catch (e) {
      // Statistik gagal tidak perlu crash halaman
      debugPrint('Gagal load statistik: $e');
    }
  }

  // ─── FILTER STATUS ────────────────────────────────────────────────────────
  void filterStatus(String? status) {
    statusFilter = status;
    currentPage = 1;
    loadTransaksi();
  }

  // ─── SEARCH ───────────────────────────────────────────────────────────────
  void search(String query) {
    searchQuery = query;
    currentPage = 1;
    loadTransaksi();
  }

  // ─── PINDAH HALAMAN ───────────────────────────────────────────────────────
  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    currentPage = page;
    loadTransaksi();
  }

  void nextPage() => goToPage(currentPage + 1);
  void prevPage() => goToPage(currentPage - 1);

  // ─── FORMAT RUPIAH ────────────────────────────────────────────────────────
  String formatRupiah(int amount) {
    final formatted = amount
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $formatted';
  }
}