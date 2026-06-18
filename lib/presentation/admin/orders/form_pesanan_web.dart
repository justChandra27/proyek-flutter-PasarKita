//lib/presentation/admin/orders/form_pesanan_web.dart
//Elsyana
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';
import '../../../core/services/order_service_appwrite.dart';
import '../../../core/services/storage_service_appwrite.dart';
import '../../../data/models/order_model.dart';

class FormPesananWeb extends StatefulWidget {
  const FormPesananWeb({super.key});

  @override
  State<FormPesananWeb> createState() => _FormPesananWebState();
}

class _FormPesananWebState extends State<FormPesananWeb> {
  final _orderService = OrderServiceAppwrite();
  final _searchController = TextEditingController();

  List<OrderModel> _orders = [];
  Map<String, int> _stats = {};
  int _totalCount = 0;
  bool _loading = true;
  String? _error;
  String? _statusFilter;
  String? _searchQuery;

  final _pageCursors = <String?>[null];
  int _currentPage = 0;
  bool _hasMore = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _orderService.getOrderStatistics(),
        _orderService.getAdminOrdersPage(
          limit: 25,
          cursor: _pageCursors[_currentPage],
          status: _statusFilter,
          search: _searchQuery,
        ),
      ]);

      final stats = results[0] as Map<String, int>;
      final page = results[1] as AdminOrdersPage;

      if (!mounted) return;
      setState(() {
        _stats = stats;
        _orders = page.orders;
        _totalCount = page.total;
        _hasMore = page.orders.length >= 25;
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

  Future<void> _loadPage() async {
    try {
      final page = await _orderService.getAdminOrdersPage(
        limit: 25,
        cursor: _pageCursors[_currentPage],
        status: _statusFilter,
        search: _searchQuery,
      );

      if (!mounted) return;
      setState(() {
        _orders = page.orders;
        _totalCount = page.total;
        _hasMore = page.orders.length >= 25;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _orderService.getOrderStatistics();
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (_) {}
  }

  void _onSearch() {
    _searchQuery = _searchController.text.trim();
    if (_searchQuery!.isEmpty) _searchQuery = null;
    _currentPage = 0;
    _pageCursors.clear();
    _pageCursors.add(null);
    _loadData();
  }

  void _setStatusFilter(String? status) {
    _statusFilter = status;
    _currentPage = 0;
    _pageCursors.clear();
    _pageCursors.add(null);
    _loadData();
  }

  void _nextPage() {
    if (!_hasMore || _orders.isEmpty) return;
    final lastId = _orders.last.id;
    _pageCursors.add(lastId);
    _currentPage++;
    _loadPage();
  }

  void _prevPage() {
    if (_currentPage <= 0) return;
    _currentPage--;
    _pageCursors.removeLast();
    _loadPage();
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatCurrency(int amount) {
    if (amount == 0) return 'Rp 0';
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.deepPurple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String _adminPaymentStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'unpaid':
        return 'Menunggu Pembayaran';
      case 'verification':
        return 'Menunggu Verifikasi';
      case 'paid':
        return 'Lunas';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  void _viewReceipt(String fileId) {
    final url = StorageServiceAppwrite().getImageUrl(fileId);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bukti Transfer'),
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
                  Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey)),
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

  void _viewReceiptPdf(String fileId) async {
    try {
      final bytes = await AppwriteService.storage.getFileDownload(
        bucketId: AppwriteConfig.productBucketId,
        fileId: fileId,
      );
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) => bytes,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka struk: $e')),
      );
    }
  }

  void _showDetailDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detail Pesanan #${order.orderCode}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Pelanggan', order.customerName),
              _detailRow('Email', order.customerEmail),
              _detailRow('Tanggal', _formatDate(order.createdAt)),
              _detailRow('Total', _formatCurrency(order.totalAmount)),
              _detailRow('Status', _statusLabel(order.status)),
              _detailRow('Metode', order.paymentMethod),
              _detailRow('Pembayaran', _adminPaymentStatusLabel(order.paymentStatus)),
              if (order.bankName.isNotEmpty) _detailRow('Bank Tujuan', order.bankName),
              if (order.senderName.isNotEmpty) _detailRow('Nama Pengirim', order.senderName),
              if (order.address.isNotEmpty) _detailRow('Alamat', order.address),
              if (order.notes.isNotEmpty) _detailRow('Catatan', order.notes),
              if (order.paymentReceiptImage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextButton.icon(
                    onPressed: () => _viewReceipt(order.paymentReceiptImage),
                    icon: const Icon(Icons.image, size: 18),
                    label: const Text('Lihat Bukti Transfer'),
                  ),
                ),
              if (order.receiptPdfFileId.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TextButton.icon(
                    onPressed: () => _viewReceiptPdf(order.receiptPdfFileId),
                    icon: const Icon(Icons.description, size: 18),
                    label: const Text('Lihat Struk'),
                  ),
                ),
            ],
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showStatusMenu(OrderModel order) {
    final current = order.status.toLowerCase();
    List<Map<String, String>> options;

    if (current == 'pending') {
      options = [
        {'value': 'processing', 'label': 'Proses'},
        {'value': 'cancelled', 'label': 'Batalkan'},
      ];
    } else if (current == 'processing') {
      options = [
        {'value': 'shipped', 'label': 'Kirim'},
        {'value': 'cancelled', 'label': 'Batalkan'},
      ];
    } else if (current == 'shipped') {
      options = [
        {'value': 'completed', 'label': 'Selesaikan'},
      ];
    } else {
      options = [];
    }

    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada perubahan status yang tersedia')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return ListTile(
              title: Text(opt['label']!),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  await _orderService.updateOrderStatus(
                    orderId: order.id,
                    status: opt['value']!,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Status #${order.orderCode} → ${_statusLabel(opt['value']!)}',
                      ),
                    ),
                  );
                  _loadStats();
                  _loadPage();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e')),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          if (order.paymentStatus == 'verification') ...['setujui', 'tolak'].map((action) {
            final isApprove = action == 'setujui';
            return TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  if (isApprove) {
                    await _orderService.approvePayment(order.id);
                  } else {
                    await _orderService.rejectPayment(order.id);
                  }
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isApprove
                            ? 'Pembayaran #${order.orderCode} disetujui'
                            : 'Pembayaran #${order.orderCode} ditolak',
                      ),
                      backgroundColor: isApprove ? Colors.green : Colors.red,
                    ),
                  );
                  _loadStats();
                  _loadPage();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: isApprove ? Colors.green : Colors.red,
              ),
              child: Text(isApprove ? 'Setujui Pembayaran' : 'Tolak Pembayaran'),
            );
          }),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
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
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _onSearch(),
                      decoration: InputDecoration(
                        hintText: "Cari pesanan atau pelanggan...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                const CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150",
                  ),
                ),

                const SizedBox(width: 10),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Admin Utama",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Administrator",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            // TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Daftar Pesanan",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Pantau dan kelola semua pesanan pelanggan Anda.",
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ACTION BUTTON
            Row(
              children: [
                if (_statusFilter != null)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff2563EB).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _statusLabel(_statusFilter!),
                          style: const TextStyle(
                            color: Color(0xff2563EB),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _setStatusFilter(null),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xff2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () => _showFilterDialog(),
                  icon: const Icon(Icons.filter_alt_outlined),
                  label: const Text("Filter"),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
                  ),
                  onPressed: () {},
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Ekspor CSV",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // STAT CARD
            if (_loading && _stats.isEmpty)
              const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      Icons.shopping_cart_outlined,
                      "TOTAL PESANAN",
                      _formatNumber(_stats['total'] ?? 0),
                      const Color(0xff2563EB),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard(
                      Icons.pending_actions,
                      "PENDING",
                      _formatNumber(_stats['pending'] ?? 0),
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard(
                      Icons.local_shipping_outlined,
                      "DIKIRIM",
                      _formatNumber(_stats['shipped'] ?? 0),
                      Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard(
                      Icons.check_circle_outline,
                      "SELESAI",
                      _formatNumber(_stats['completed'] ?? 0),
                      Colors.green,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // TABLE
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: _loading && _orders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null && _orders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gagal memuat data',
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _loadData,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return SingleChildScrollView(
                                      child: SizedBox(
                                        width: constraints.maxWidth,
                                        child: DataTable(
                                          columnSpacing: 80,
                                          horizontalMargin: 24,
                                    headingRowColor:
                                        WidgetStateProperty.all(
                                      const Color(0xffF8F9FC),
                                    ),
                                    columns: const [
                                      DataColumn(label: Text("Order ID")),
                                      DataColumn(label: Text("Pelanggan")),
                                      DataColumn(label: Text("Tanggal")),
                                      DataColumn(label: Text("Total Amount")),
                                      DataColumn(label: Text("Status")),
                                      DataColumn(label: Text("Aksi")),
                                    ],
                                    rows: _orders.map((order) {
                                      final initials = order.customerName
                                          .split(' ')
                                          .map((e) => e.isNotEmpty ? e[0] : '')
                                          .take(2)
                                          .join()
                                          .toUpperCase();
                                      final color = _statusColor(order.status);
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Text(
                                              order.orderCode,
                                              style: const TextStyle(
                                                color: Color(0xff2563EB),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 16,
                                                  backgroundColor: Colors.blue
                                                      .withValues(alpha: .15),
                                                  child: Text(
                                                    initials,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(order.customerName),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                            Text(_formatDate(order.createdAt)),
                                          ),
                                          DataCell(
                                            Text(
                                              _formatCurrency(
                                                order.totalAmount,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: color
                                                    .withValues(alpha: .15),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                _statusLabel(order.status),
                                                style: TextStyle(
                                                  color: color,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            PopupMenuButton<String>(
                                              icon: const Icon(
                                                Icons.more_vert,
                                              ),
                                              onSelected: (value) {
                                                if (value == 'detail') {
                                                  _showDetailDialog(order);
                                                } else if (value == 'status') {
                                                  _showStatusMenu(order);
                                                }
                                              },
                                              itemBuilder: (_) => [
                                                const PopupMenuItem(
                                                  value: 'detail',
                                                  child: Text('Lihat Detail'),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'status',
                                                  child: Text('Ubah Status'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 18,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      _totalCount > 0
                                          ? 'Menampilkan ${_currentPage * 25 + 1}–${(_currentPage * 25 + _orders.length).clamp(0, _totalCount)} dari ${_formatNumber(_totalCount)} pesanan'
                                          : 'Tidak ada pesanan',
                                    ),
                                    const Spacer(),
                                    _pageButton("<", _currentPage > 0, () {
                                      _prevPage();
                                    }),
                                    _pageButton(
                                      (_currentPage + 1).toString(),
                                      true,
                                      null,
                                    ),
                                    _pageButton(">", _hasMore, () {
                                      _nextPage();
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Filter Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Semua'),
              selected: _statusFilter == null,
              onTap: () {
                Navigator.pop(ctx);
                _setStatusFilter(null);
              },
            ),
            ...['pending', 'processing', 'shipped', 'completed', 'cancelled']
                .map(
                  (s) => ListTile(
                    title: Text(_statusLabel(s)),
                    selected: _statusFilter == s,
                    onTap: () {
                      Navigator.pop(ctx);
                      _setStatusFilter(s);
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n == 0) return '0';
    final str = n.toString();
    final parts = <String>[];
    int end = str.length;
    while (end > 0) {
      final start = (end - 3).clamp(0, end);
      parts.insert(0, str.substring(start, end));
      end = start;
    }
    return parts.join('.');
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _pageButton(
    String text,
    bool active,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: active
              ? const Color(0xff2563EB)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xffE5E7EB),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: active
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
