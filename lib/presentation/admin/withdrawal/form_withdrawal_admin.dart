import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/withdrawal_service_appwrite.dart';
import '../../../data/models/withdrawal_model.dart';

class _WithdrawalDisplayItem {
  final WithdrawalModel withdrawal;
  final String sellerName;
  final String storeName;

  _WithdrawalDisplayItem({
    required this.withdrawal,
    required this.sellerName,
    required this.storeName,
  });
}

class FormWithdrawalAdmin extends StatefulWidget {
  const FormWithdrawalAdmin({super.key});

  @override
  State<FormWithdrawalAdmin> createState() => _FormWithdrawalAdminState();
}

class _FormWithdrawalAdminState extends State<FormWithdrawalAdmin> {
  final WithdrawalServiceAppwrite _withdrawalService = WithdrawalServiceAppwrite();
  final Databases _db = AppwriteService.databases;
  final TextEditingController _searchController = TextEditingController();

  List<_WithdrawalDisplayItem> _allItems = [];
  List<_WithdrawalDisplayItem> _filteredItems = [];
  bool _loading = true;
  String? _error;
  String _adminId = '';

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applySearch();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final account = await AuthServiceAppwrite().getCurrentUser();
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.withdrawalsCollectionId,
        queries: [
          Query.orderDesc('requestedAt'),
          Query.limit(5000),
        ],
      );
      final withdrawals = result.documents
          .map((doc) => WithdrawalModel.fromMap(doc.$id, doc.data))
          .toList();

      final sellerIds = withdrawals
          .map((w) => w.sellerId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final sellerData = await _batchFetchSellerData(sellerIds);

      final items = withdrawals.map((w) {
        final data = sellerData[w.sellerId] ?? <String, String>{};
        return _WithdrawalDisplayItem(
          withdrawal: w,
          sellerName: data['name'] ?? 'Unknown',
          storeName: data['storeName'] ?? '',
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _adminId = account.$id;
        _allItems = items;
        _loading = false;
      });
      _applySearch();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<Map<String, Map<String, String>>> _batchFetchSellerData(
      List<String> sellerIds) async {
    final map = <String, Map<String, String>>{};
    for (var i = 0; i < sellerIds.length; i += 100) {
      final chunk = sellerIds.sublist(i, (i + 100).clamp(0, sellerIds.length));
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('\$id', chunk)],
      );
      for (final doc in result.documents) {
        map[doc.$id] = {
          'name': doc.data['name'] as String? ?? 'Unknown',
          'storeName': doc.data['storeName'] as String? ?? '',
        };
      }
    }
    return map;
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredItems = _allItems.where((item) {
        if (query.isEmpty) return true;
        final wId = item.withdrawal.id.toLowerCase();
        final sellerId = item.withdrawal.sellerId.toLowerCase();
        final seller = item.sellerName.toLowerCase();
        final store = item.storeName.toLowerCase();
        return wId.contains(query) ||
            sellerId.contains(query) ||
            seller.contains(query) ||
            store.contains(query);
      }).toList();
    });
  }

  Map<String, int> get _stats {
    final total = _filteredItems.length;
    final pending = _filteredItems.where((i) => i.withdrawal.status == 'pending').length;
    final approved = _filteredItems.where((i) => i.withdrawal.status == 'approved').length;
    final rejected = _filteredItems.where((i) => i.withdrawal.status == 'rejected').length;
    return {
      'total': total,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }

  String _formatPrice(int price) {
    final p = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
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

  String _shortId(String id) {
    return id.length > 8 ? 'WD-${id.substring(0, 8).toUpperCase()}' : 'WD-$id';
  }

  Future<void> _approve(WithdrawalModel w) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui Penarikan'),
        content: Text(
          'Setujui penarikan ${_formatPrice(w.amount)} dari seller ${w.sellerId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _withdrawalService.approveWithdrawal(w.id, _adminId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penarikan disetujui'),
            backgroundColor: Colors.green,
          ),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _reject(WithdrawalModel w) async {
    final reasonCtrl = TextEditingController();
    final rejected = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Penarikan'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: 'Alasan penolakan',
            hintText: 'Wajib diisi',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan wajib diisi')),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (rejected != true) return;

    try {
      await _withdrawalService.rejectWithdrawal(
        withdrawalId: w.id,
        adminId: _adminId,
        note: reasonCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penarikan ditolak'),
            backgroundColor: Colors.orange,
          ),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
    reasonCtrl.dispose();
  }

  void _showDetailDialog(_WithdrawalDisplayItem item) {
    final w = item.withdrawal;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Detail Penarikan',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(w.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _statusLabel(w.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _statusColor(w.status),
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Withdrawal ID', _shortId(w.id)),
                _detailRow('Seller', item.sellerName),
                if (item.storeName.isNotEmpty)
                  _detailRow('Nama Toko', item.storeName),
                _detailRow('Bank', w.bankName),
                _detailRow('No. Rekening', w.bankAccount),
                _detailRow('Nama Pemilik', w.accountName),
                _detailRow('Nominal', _formatPrice(w.amount)),
                _detailRow('Status', _statusLabel(w.status)),
                _detailRow('Tanggal Request', _formatDate(w.requestedAt)),
                if (w.processedAt.isNotEmpty)
                  _detailRow('Diproses', _formatDate(w.processedAt)),
                if (w.adminNote.isNotEmpty)
                  _detailRow('Catatan Admin', w.adminNote),
              ],
            ),
          ),
        ),
        actions: [
          if (w.status.toLowerCase() == 'pending') ...[
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _reject(w);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Tolak'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _approve(w);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Setujui'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (!_loading && _error == null) ...[
              _buildStatCards(),
              const SizedBox(height: 24),
            ],
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Penarikan',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 380,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari seller, toko, atau ID...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xff2962FF),
          child: const Text('A', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    final stats = _stats;
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.account_balance_wallet,
            'TOTAL',
            stats['total'].toString(),
            const Color(0xff2563EB),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            Icons.pending_actions,
            'PENDING',
            stats['pending'].toString(),
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            Icons.check_circle_outline,
            'APPROVED',
            stats['approved'].toString(),
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            Icons.cancel_outlined,
            'REJECTED',
            stats['rejected'].toString(),
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String title, String value, Color color) {
    return Container(
      height: 90,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data',
              style: TextStyle(color: Colors.red[700]),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Tidak ada hasil untuk "${_searchController.text}"'
                  : 'Tidak ada pengajuan penarikan',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
        columns: const [
          DataColumn(label: Text('Withdrawal ID')),
          DataColumn(label: Text('Seller')),
          DataColumn(label: Text('Bank')),
          DataColumn(label: Text('No. Rekening')),
          DataColumn(label: Text('Jumlah')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Tanggal')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: _filteredItems.map((item) {
          final w = item.withdrawal;
          final color = _statusColor(w.status);
          return DataRow(cells: [
            DataCell(Text(
              _shortId(w.id),
              style: const TextStyle(fontWeight: FontWeight.w600),
            )),
            DataCell(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.sellerName, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (item.storeName.isNotEmpty)
                  Text(item.storeName, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            )),
            DataCell(Text(w.bankName)),
            DataCell(Text(w.bankAccount)),
            DataCell(Text(
              _formatPrice(w.amount),
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _statusLabel(w.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            )),
            DataCell(Text(_formatDate(w.requestedAt))),
            DataCell(Row(
              children: [
                TextButton(
                  onPressed: () => _showDetailDialog(item),
                  child: const Text('Detail'),
                ),
                if (w.status.toLowerCase() == 'pending') ...[
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _approve(w),
                      child: const Text('Setujui'),
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    height: 32,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _reject(w),
                      child: const Text('Tolak'),
                    ),
                  ),
                ],
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
