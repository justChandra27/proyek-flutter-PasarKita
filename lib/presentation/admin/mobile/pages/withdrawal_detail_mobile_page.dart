import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../core/services/withdrawal_service_appwrite.dart';
import '../../../../core/services/auth_service_appwrite.dart';
import '../../../../data/models/withdrawal_model.dart';

class WithdrawalDetailMobilePage extends StatefulWidget {
  final String withdrawalId;

  const WithdrawalDetailMobilePage(
      {super.key, required this.withdrawalId});

  @override
  State<WithdrawalDetailMobilePage> createState() =>
      _WithdrawalDetailMobilePageState();
}

class _WithdrawalDetailMobilePageState
    extends State<WithdrawalDetailMobilePage> {
  final WithdrawalServiceAppwrite _withdrawalService =
      WithdrawalServiceAppwrite();
  final AuthServiceAppwrite _authService = AuthServiceAppwrite();
  final Databases _db = AppwriteService.databases;

  WithdrawalModel? _withdrawal;
  String _sellerName = '';
  String _storeName = '';
  String _adminId = '';
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
      final doc = await _db.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.withdrawalsCollectionId,
        documentId: widget.withdrawalId,
      );
      final withdrawal =
          WithdrawalModel.fromMap(doc.$id, doc.data);

      String sellerName = '';
      String storeName = '';
      if (withdrawal.sellerId.isNotEmpty) {
        try {
          final userDoc = await _db.getDocument(
            databaseId: AppwriteConfig.databaseId,
            collectionId: AppwriteConfig.usersCollectionId,
            documentId: withdrawal.sellerId,
          );
          sellerName =
              userDoc.data['name'] as String? ?? '';
          storeName =
              userDoc.data['storeName'] as String? ?? '';
        } catch (_) {}
      }

      final userData = await _authService.getCurrentUserData();
      final adminId = (userData?['uid'] as String?) ?? '';

      if (!mounted) return;
      setState(() {
        _withdrawal = withdrawal;
        _sellerName = sellerName;
        _storeName = storeName;
        _adminId = adminId;
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

  Future<void> _approveWithdrawal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text(
            'Yakin ingin menyetujui pencairan dana ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
    if (confirmed != true || _adminId.isEmpty) return;

    setState(() => _actionLoading = true);
    try {
      await _withdrawalService.approveWithdrawal(
        widget.withdrawalId,
        _adminId,
      );
      await _loadDetail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal berhasil disetujui'),
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

  Future<void> _rejectWithdrawal() async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Yakin ingin menolak pencairan dana ini?'),
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
    if (confirmed != true || _adminId.isEmpty) return;

    final note = noteController.text.trim();
    if (note.isEmpty) {
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
      await _withdrawalService.rejectWithdrawal(
        withdrawalId: widget.withdrawalId,
        adminId: _adminId,
        note: note,
      );
      await _loadDetail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Withdrawal ditolak'),
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
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
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

  String _formatAmount(int amount) {
    final str = amount.toString();
    final parts = <String>[];
    int end = str.length;
    while (end > 0) {
      final start = (end - 3).clamp(0, end);
      parts.insert(0, str.substring(start, end));
      end = start;
    }
    return 'Rp ${parts.join('.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: const Text('Detail Withdrawal',
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

    final w = _withdrawal!;

    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard('Informasi Withdrawal', [
              _infoRow(Icons.receipt, 'Withdrawal ID',
                  w.id.length > 12 ? w.id.substring(0, 12) : w.id),
              if (_sellerName.isNotEmpty)
                _infoRow(Icons.person, 'Seller', _sellerName),
              if (_storeName.isNotEmpty)
                _infoRow(Icons.store, 'Store', _storeName),
              if (w.bankName.isNotEmpty)
                _infoRow(Icons.account_balance, 'Bank', w.bankName),
              if (w.bankAccount.isNotEmpty)
                _infoRow(Icons.credit_card, 'No. Rekening', w.bankAccount),
              if (w.accountName.isNotEmpty)
                _infoRow(Icons.badge, 'Nama Pemilik', w.accountName),
              _infoRow(
                Icons.money,
                'Nominal',
                _formatAmount(w.amount),
              ),
              _infoRow(
                Icons.info_outline,
                'Status',
                _statusLabel(w.status),
                valueColor: _statusColor(w.status),
              ),
              if (w.requestedAt.isNotEmpty)
                _infoRow(
                    Icons.calendar_today, 'Tanggal Request',
                    _formatDate(w.requestedAt)),
              if (w.processedAt.isNotEmpty)
                _infoRow(Icons.check_circle_outline, 'Diproses',
                    _formatDate(w.processedAt)),
              if (w.adminNote.isNotEmpty)
                _infoRow(Icons.comment, 'Catatan Admin', w.adminNote),
            ]),
            if (w.status.toLowerCase() == 'pending') ...[
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _actionLoading ? null : _rejectWithdrawal,
              icon: _actionLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.close),
              label: const Text('Tolak'),
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
              onPressed: _actionLoading ? null : _approveWithdrawal,
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
              label: const Text('Setujui'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
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
