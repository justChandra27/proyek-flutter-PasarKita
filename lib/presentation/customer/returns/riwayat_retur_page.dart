import 'package:flutter/material.dart';

import '../../../core/appwrite/appwrite_service.dart';
import '../../../core/services/return_service_appwrite.dart';
import '../../../data/models/return_model.dart';

class RiwayatReturPage extends StatefulWidget {
  const RiwayatReturPage({super.key});

  @override
  State<RiwayatReturPage> createState() => _RiwayatReturPageState();
}

class _RiwayatReturPageState extends State<RiwayatReturPage> {
  final _returnService = ReturnServiceAppwrite();
  List<ReturnModel> _returns = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final account = await AppwriteService.account.get();
      final returns = await _returnService.getReturnsByCustomer(account.$id);
      if (!mounted) return;
      setState(() {
        _returns = returns;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'requested':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'received':
        return 'Diterima';
      case 'refunded':
        return 'Dikembalikan';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'received':
        return Colors.deepPurple;
      case 'refunded':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Riwayat Retur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 8),
                      Text('Gagal memuat data',
                          style: TextStyle(color: Colors.red[700])),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadReturns,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _returns.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada pengajuan retur',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _returns.length,
                      itemBuilder: (context, index) {
                        final retur = _returns[index];
                        final color = _statusColor(retur.status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: .15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _statusLabel(retur.status),
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      retur.orderCode,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff2563EB),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _infoRow('Alasan', retur.reason),
                                if (retur.description.isNotEmpty)
                                  _infoRow('Deskripsi', retur.description),
                                if (retur.adminNote.isNotEmpty)
                                  _infoRow('Catatan', retur.adminNote),
                                _infoRow('Tanggal',
                                    _formatDate(retur.approvedAt.isNotEmpty
                                        ? retur.approvedAt
                                        : retur.rejectedAt.isNotEmpty
                                            ? retur.rejectedAt
                                            : '')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
