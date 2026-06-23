import 'package:flutter/material.dart';

import '../../../core/appwrite/appwrite_service.dart';
import '../../../core/services/return_service_appwrite.dart';
import '../../../core/services/storage_service_appwrite.dart';
import '../../../data/models/return_model.dart';

class ReturMasukPage extends StatefulWidget {
  const ReturMasukPage({super.key});

  @override
  State<ReturMasukPage> createState() => _ReturMasukPageState();
}

class _ReturMasukPageState extends State<ReturMasukPage> {
  final _returnService = ReturnServiceAppwrite();
  List<ReturnModel> _returns = [];
  bool _loading = true;
  String? _error;
  String _sellerId = '';

  @override
  void initState() {
    super.initState();
    _loadSellerAndReturns();
  }

  Future<void> _loadSellerAndReturns() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final account = await AppwriteService.account.get();
      _sellerId = account.$id;
      final returns = await _returnService.getReturnsBySeller(_sellerId);
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
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Retur Masuk',
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
                        onPressed: _loadSellerAndReturns,
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
                        return _returCard(retur);
                      },
                    ),
    );
  }

  Widget _returCard(ReturnModel retur) {
    final color = _statusColor(retur.status);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
            _infoRow('Tanggal', _formatDate(retur.approvedAt.isNotEmpty
                ? retur.approvedAt
                : retur.rejectedAt.isNotEmpty
                    ? retur.rejectedAt
                    : '')),
            if (retur.adminNote.isNotEmpty)
              _infoRow('Catatan Admin', retur.adminNote),
            if (retur.photoUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: retur.photoUrls.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final url = StorageServiceAppwrite()
                        .getImageUrl(retur.photoUrls[i]);
                    return GestureDetector(
                      onTap: () => _viewPhoto(url),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (retur.status == 'requested') ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectDialog(retur),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveReturn(retur),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Setujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _viewPhoto(String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Foto Retur'),
        content: SizedBox(
          width: 400,
          child: InteractiveViewer(
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  Text('Gagal memuat gambar'),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveReturn(ReturnModel retur) async {
    try {
      await _returnService.approveReturn(retur.id, _sellerId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Retur ${retur.orderCode} disetujui'),
          backgroundColor: Colors.green,
        ),
      );
      _loadSellerAndReturns();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showRejectDialog(ReturnModel retur) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Retur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Alasan penolakan wajib diisi:'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Masukkan alasan penolakan...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final note = noteController.text.trim();
              if (note.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan wajib diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              try {
                await _returnService.rejectReturn(
                    retur.id, _sellerId, note);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Retur ${retur.orderCode} ditolak'),
                    backgroundColor: Colors.red,
                  ),
                );
                _loadSellerAndReturns();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Gagal: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}
