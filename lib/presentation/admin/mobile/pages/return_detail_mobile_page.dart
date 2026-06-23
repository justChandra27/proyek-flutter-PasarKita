import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../core/services/return_service_appwrite.dart';
import '../../../../core/services/storage_service_appwrite.dart';
import '../../../../data/models/return_model.dart';

class ReturnDetailMobilePage extends StatefulWidget {
  final String returnId;

  const ReturnDetailMobilePage({super.key, required this.returnId});

  @override
  State<ReturnDetailMobilePage> createState() =>
      _ReturnDetailMobilePageState();
}

class _ReturnDetailMobilePageState extends State<ReturnDetailMobilePage> {
  final ReturnServiceAppwrite _returnService = ReturnServiceAppwrite();
  final StorageServiceAppwrite _storageService = StorageServiceAppwrite();
  final Databases _db = AppwriteService.databases;

  ReturnModel? _return;
  String _customerName = '';
  String _productName = '';
  bool _loading = true;
  String? _error;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final returnData =
          await _returnService.getReturnById(widget.returnId);
      if (!mounted) return;
      if (returnData == null) {
        setState(() {
          _error = 'Retur tidak ditemukan';
          _loading = false;
        });
        return;
      }

      String customerName = '';
      String productName = '';

      if (returnData.orderId.isNotEmpty) {
        try {
          final orderDoc = await _db.getDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.ordersCollectionId,
            documentId: returnData.orderId,
          );
          customerName =
              orderDoc.data['customerName'] as String? ?? '';
        } catch (_) {}
      }

      if (returnData.orderItemId.isNotEmpty) {
        try {
          final itemDoc = await _db.getDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.orderItemsCollectionId,
            documentId: returnData.orderItemId,
          );
          productName =
              itemDoc.data['productName'] as String? ?? '';
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _return = returnData;
        _customerName = customerName;
        _productName = productName;
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

  Future<void> _approveReturn() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menyetujui retur ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (_return == null) return;
    setState(() => _actionLoading = true);
    try {
      await _returnService.approveReturn(
        _return!.id,
        _return!.sellerId,
      );
      await _loadDetail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retur berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _rejectReturn() async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yakin ingin menolak retur ini?'),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: 'Alasan penolakan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (_return == null) return;
    final adminNote = noteController.text.trim();
    if (adminNote.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi alasan penolakan'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _actionLoading = true);
    try {
      await _returnService.rejectReturn(
        _return!.id,
        _return!.sellerId,
        adminNote,
      );
      await _loadDetail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Retur ditolak'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'received':
        return Colors.purple;
      case 'refunded':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'requested':
        return 'Requested';
      case 'approved':
        return 'Approved';
      case 'received':
        return 'Received';
      case 'refunded':
        return 'Refunded';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}, '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: const Text('Detail Retur',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final r = _return!;

    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard('Informasi Retur', [
              _infoRow(Icons.receipt, 'Return ID',
                  r.id.length > 12 ? r.id.substring(0, 12) : r.id),
              _infoRow(
                  Icons.shopping_bag, 'Order Code', r.orderCode),
              if (_customerName.isNotEmpty)
                _infoRow(Icons.person, 'Customer', _customerName),
              if (_productName.isNotEmpty)
                _infoRow(Icons.inventory_2, 'Produk', _productName),
              _infoRow(
                Icons.info_outline,
                'Status',
                _statusLabel(r.status),
                valueColor: _statusColor(r.status),
              ),
              _infoRow(Icons.report_problem, 'Alasan', r.reason),
              if (r.description.isNotEmpty)
                _infoRow(Icons.notes, 'Deskripsi', r.description),
              _infoRow(Icons.access_time, 'Tanggal Pengajuan',
                  _formatDate(r.returnDeadline)),
              if (r.adminNote.isNotEmpty)
                _infoRow(Icons.comment, 'Catatan Admin', r.adminNote),
            ]),
            const SizedBox(height: 12),
            _buildPhotoSection(r),
            if (r.status.toLowerCase() == 'requested') ...[
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? const Color(0xff111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(ReturnModel r) {
    final hasPhotos = r.photoUrls.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto Retur',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 12),
          if (hasPhotos)
            ...r.photoUrls.map((fileId) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _storageService.getImageUrl(fileId),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder:
                          (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Center(
                            child:
                                CircularProgressIndicator(
                              value: loadingProgress
                                          .expectedTotalBytes !=
                                      null
                                  ? loadingProgress
                                          .cumulativeBytesLoaded /
                                      loadingProgress
                                          .expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder:
                          (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image,
                                    size: 32,
                                    color: Colors.red.shade300),
                                const SizedBox(height: 4),
                                Text(
                                  'Gagal memuat gambar',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Colors.red.shade400),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ))
          else
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade200,
                    style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_outlined,
                        size: 28, color: Colors.grey.shade400),
                    const SizedBox(height: 4),
                    Text(
                      'Belum ada foto retur',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _actionLoading ? null : _rejectReturn,
              icon: _actionLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    )
                  : const Icon(Icons.close),
              label: const Text('Tolak Retur'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _actionLoading ? null : _approveReturn,
              icon: _actionLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text('Setujui Retur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
