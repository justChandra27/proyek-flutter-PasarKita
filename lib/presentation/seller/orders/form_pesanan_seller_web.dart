//lib/presentation/seller/orders/form_pesanan_seller_web.dart

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import 'package:appwrite/appwrite.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/order_service_appwrite.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/order_item_model.dart';
import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';
import '../../../core/services/csv_export_service.dart';
import '../../../core/services/storage_service_appwrite.dart';

class FormPesananSellerWeb extends StatefulWidget {
  const FormPesananSellerWeb({super.key});

  @override
  State<FormPesananSellerWeb> createState() =>
      _FormPesananSellerWebState();
}

class _FormPesananSellerWebState
    extends State<FormPesananSellerWeb> {
  final OrderServiceAppwrite _orderService = OrderServiceAppwrite();
  String? _sellerId;
  String _sellerName = 'Seller';
  String _initial = 'S';

  List<Map<String, dynamic>> _allOrders = [];
  bool _isLoading = true;
  String? _error;

  String _activeTab = 'semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'terbaru';

  Set<String> _filterStatuses = {};
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  int? _filterMinTotal;
  int? _filterMaxTotal;

  int _currentPage = 1;
  static const int _pageSize = 10;

  int get _totalPages => (_filteredOrders.length + _pageSize - 1) ~/ _pageSize;

  List<Map<String, dynamic>> get _pagedOrders {
    final start = (_currentPage - 1) * _pageSize;
    if (start >= _filteredOrders.length) return [];
    final end = start + _pageSize;
    return _filteredOrders.sublist(start, end > _filteredOrders.length ? _filteredOrders.length : end);
  }

  bool get _hasActiveFilter =>
      _filterStatuses.isNotEmpty ||
      _filterStartDate != null ||
      _filterEndDate != null ||
      _filterMinTotal != null ||
      _filterMaxTotal != null;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
        _currentPage = 1;
      });
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final auth = AuthServiceAppwrite();
      final account = await auth.getCurrentUser();
      _sellerId = account.$id;
      final databases = AppwriteService.databases;
      final userResult = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('uid', account.$id), Query.limit(1)],
      );
      final name = account.name;
      if (userResult.documents.isNotEmpty) {
        final data = userResult.documents.first.data;
        final displayName = (data['storeName'] as String?)?.isNotEmpty == true
            ? data['storeName'] as String
            : name;
        _sellerName = displayName;
        _initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
      } else {
        _sellerName = name;
        _initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
      }
      final orders = await _orderService.getSellerOrdersWithDetails(account.$id);
      if (mounted) setState(() { _allOrders = orders; _currentPage = 1; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
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

  int _subtotal(Map<String, dynamic> entry) {
    final items = entry['items'] as List<OrderItemModel>;
    return items.fold<int>(0, (s, i) => s + i.subtotal);
  }

  List<Map<String, dynamic>> get _filteredOrders {
    var result = _allOrders.where((entry) {
      final order = entry['order'] as OrderModel;
      final items = entry['items'] as List<OrderItemModel>;

      if (_filterStatuses.isNotEmpty) {
        if (!_filterStatuses.contains(order.status.toLowerCase())) return false;
      } else {
        if (_activeTab != 'semua') {
          if (order.status.toLowerCase() != _activeTab) return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesSearch =
            order.orderCode.toLowerCase().contains(q) ||
            order.customerName.toLowerCase().contains(q) ||
            items.any((i) => i.productName.toLowerCase().contains(q));
        if (!matchesSearch) return false;
      }

      if (_filterStartDate != null || _filterEndDate != null) {
        final orderDate = DateTime.tryParse(order.createdAt);
        if (orderDate != null) {
          if (_filterStartDate != null && orderDate.isBefore(_filterStartDate!)) return false;
          if (_filterEndDate != null) {
            final endOfDay = DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day, 23, 59, 59);
            if (orderDate.isAfter(endOfDay)) return false;
          }
        }
      }

      if (_filterMinTotal != null || _filterMaxTotal != null) {
        if (_filterMinTotal != null && order.totalAmount < _filterMinTotal!) return false;
        if (_filterMaxTotal != null && order.totalAmount > _filterMaxTotal!) return false;
      }

      return true;
    }).toList();

    switch (_sortBy) {
      case 'terlama':
        result.sort((a, b) => (a['order'] as OrderModel).createdAt
            .compareTo((b['order'] as OrderModel).createdAt));
        break;
      case 'total_tertinggi':
        result.sort((a, b) => (b['order'] as OrderModel).totalAmount.compareTo((a['order'] as OrderModel).totalAmount));
        break;
      case 'total_terendah':
        result.sort((a, b) => (a['order'] as OrderModel).totalAmount.compareTo((b['order'] as OrderModel).totalAmount));
        break;
      default:
        result.sort((a, b) => (b['order'] as OrderModel).createdAt
            .compareTo((a['order'] as OrderModel).createdAt));
    }

    return result;
  }

  int get _pendingCount => _allOrders.where((e) =>
      (e['order'] as OrderModel).status.toLowerCase() == 'pending').length;

  int get _shippedCount => _allOrders.where((e) =>
      (e['order'] as OrderModel).status.toLowerCase() == 'shipped').length;

  int get _totalRevenue => _allOrders
      .where((e) => (e['order'] as OrderModel).status.toLowerCase() == 'completed')
      .fold<int>(0, (sum, entry) => sum + _subtotal(entry));

  String get _sortLabel {
    switch (_sortBy) {
      case 'terlama': return 'Urutkan: Terlama';
      case 'total_tertinggi': return 'Urutkan: Total Tertinggi';
      case 'total_terendah': return 'Urutkan: Total Terendah';
      default: return 'Urutkan: Terbaru';
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return const Color(0xff2563EB);
      case 'delivered':
      case 'completed':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PERLU DIPROSES';
      case 'processing':
        return 'DIPROSES';
      case 'shipped':
        return 'DIKIRIM';
      case 'delivered':
        return 'SELESAI';
      case 'completed':
        return 'SELESAI';
      case 'cancelled':
        return 'DIBATALKAN';
      default:
        return status.toUpperCase();
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'unpaid':
        return 'Menunggu Pembayaran';
      case 'verification':
        return 'Perlu Verifikasi';
      case 'paid':
        return 'Pembayaran Berhasil';
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
            onPressed: () => Navigator.pop(context),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Cari pesanan...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      _sellerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "Verified Merchant",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xff2563EB),
                  child: Text(
                    _initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // TITLE
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kelola Pesanan",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Pantau dan proses pesanan pelanggan Anda secara efisien.",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                  ),
                  onPressed: _exportCsv,
                  icon: const Icon(
                    Icons.download,
                    color: Color(0xff2563EB),
                  ),
                  label: const Text(
                    "Ekspor Rekap",
                    style: TextStyle(
                      color: Color(0xff2563EB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // STAT CARD
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    Icons.assignment_turned_in_outlined,
                    "Perlu Diproses",
                    "$_pendingCount Pesanan",
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    Icons.local_shipping_outlined,
                    "Sedang Dikirim",
                    "$_shippedCount Pesanan",
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    Icons.payments_outlined,
                    "Total Penjualan",
                    _formatPrice(_totalRevenue),
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // TAB
                    Container(
                      height: 50,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      child: Row(
                        children: [
                          _tab("Semua", _activeTab == 'semua', 'semua'),
                          _tab("Perlu Diproses", _activeTab == 'pending', 'pending'),
                          _tab("Dikirim", _activeTab == 'shipped', 'shipped'),
                          _tab("Selesai", _activeTab == 'completed', 'completed'),
                          _tab("Dibatalkan", _activeTab == 'cancelled', 'cancelled'),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration:
                                  InputDecoration(
                                hintText:
                                    "Cari nama pembeli atau no. pesanan",
                                prefixIcon:
                                    const Icon(
                                  Icons.search,
                                ),
                                filled: true,
                                fillColor:
                                    const Color(
                                        0xffF8FAFC),
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          PopupMenuButton<String>(
                            initialValue: _sortBy,
                            onSelected: (value) =>
                                setState(() { _sortBy = value; _currentPage = 1; }),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'terbaru', child: Text("Terbaru")),
                              const PopupMenuItem(value: 'terlama', child: Text("Terlama")),
                              const PopupMenuItem(value: 'total_tertinggi', child: Text("Total Tertinggi")),
                              const PopupMenuItem(value: 'total_terendah', child: Text("Total Terendah")),
                            ],
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration:
                                  BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                ),
                                borderRadius:
                                    BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_sortLabel),
                                  const SizedBox(width: 5),
                                  const Icon(Icons.keyboard_arrow_down),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _showFilterDialog,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _hasActiveFilter ? const Color(0xff1D4ED8) : Colors.grey.shade300,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.tune,
                                color: _hasActiveFilter ? const Color(0xff1D4ED8) : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : _error != null
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(
                                      "Gagal memuat pesanan:\n$_error",
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : _buildOrderList(),
                    ),
                    _buildPagination(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderItem({
    required OrderModel order,
    required List<OrderItemModel> items,
    required String sellerId,
  }) {
    final statusColor = _statusColor(order.status);
    final sellerSubtotal =
        items.fold<int>(0, (sum, i) => sum + i.subtotal);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),
      leading: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.receipt_long, color: Colors.grey),
      ),
      title: Row(
        children: [
          Text(
            order.orderCode,
            style: const TextStyle(
              color: Color(0xff1D4ED8),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(order.status),
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pembeli: ${order.customerName}"),
          Text(
            items
                .map((i) =>
                    "${i.productName} (${i.quantity}x ${_formatPrice(i.price)})")
                .join(", "),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _formatPrice(sellerSubtotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1D4ED8),
                  ),
                ),
              ),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          _StatusButton(order: order, sellerId: sellerId, onStatusChanged: _loadOrders),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) => _handleOrderAction(value, order, items, sellerId),
            itemBuilder: (context) => _orderActionItems(order),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
    );
  }

  List<PopupMenuEntry<String>> _orderActionItems(OrderModel order) {
    final entries = <PopupMenuEntry<String>>[
      const PopupMenuItem(value: 'detail', child: ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('Lihat Detail'),
        contentPadding: EdgeInsets.zero,
      )),
    ];

    final statusActions = _availableStatusActions(order.status);
    if (statusActions.isNotEmpty) {
      entries.add(const PopupMenuDivider());
      for (final action in statusActions) {
        entries.add(PopupMenuItem(
          value: 'status_${action['value']}',
          child: ListTile(
            leading: Icon(action['icon'] as IconData),
            title: Text(action['label'] as String),
            contentPadding: EdgeInsets.zero,
          ),
        ));
      }
    }

    entries.addAll([
      const PopupMenuDivider(),
      const PopupMenuItem(value: 'contact', child: ListTile(
        leading: Icon(Icons.phone),
        title: Text('Hubungi Pembeli'),
        contentPadding: EdgeInsets.zero,
      )),
    ]);

    return entries;
  }

  List<Map<String, dynamic>> _availableStatusActions(String currentStatus) {
    switch (currentStatus.toLowerCase()) {
      case 'pending':
        return [
          {'value': 'processing', 'label': 'Proses Pesanan', 'icon': Icons.play_arrow},
          {'value': 'cancelled', 'label': 'Batalkan Pesanan', 'icon': Icons.cancel_outlined},
        ];
      case 'processing':
        return [
          {'value': 'shipped', 'label': 'Kirim Pesanan', 'icon': Icons.local_shipping},
          {'value': 'cancelled', 'label': 'Batalkan Pesanan', 'icon': Icons.cancel_outlined},
        ];
      case 'shipped':
        return [
          {'value': 'completed', 'label': 'Selesaikan Pesanan', 'icon': Icons.check_circle},
        ];
      default:
        return [];
    }
  }

  void _handleOrderAction(String value, OrderModel order, List<OrderItemModel> items, String sellerId) {
    switch (value) {
      case 'detail':
        _showDetailDialog(order, items);
        break;
      case 'contact':
        _showContactDialog(order);
        break;
      default:
        if (value.startsWith('status_')) {
          _updateOrderStatus(order, value.substring(7), sellerId);
        }
    }
  }

  Future<void> _updateOrderStatus(OrderModel order, String newStatus, String sellerId) async {
    try {
      await _orderService.updateOrderStatus(
        orderId: order.id,
        status: newStatus,
        sellerId: sellerId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status berhasil diubah'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders();
    } on AppwriteException catch (e) {
      if (!mounted) return;
      debugPrint('ORDER STATUS ERROR | code=${e.code} | type=${e.type} | message=${e.message}');
      String message = e.message ?? 'Gagal mengubah status';
      if (e.code == 403) {
        message = 'Anda tidak memiliki akses untuk mengubah pesanan ini';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;
      debugPrint('ORDER STATUS UNEXPECTED ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showDetailDialog(OrderModel order, List<OrderItemModel> items) {
    final total = items.fold<int>(0, (sum, i) => sum + i.subtotal);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(order.orderCode, style: const TextStyle(fontWeight: FontWeight.bold))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(order.status).withValues(alpha: .15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel(order.status),
                style: TextStyle(color: _statusColor(order.status), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Informasi Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _detailRow('Tanggal', _formatDate(order.createdAt)),
                _detailRow('Pembeli', order.customerName),
                if (order.customerEmail.isNotEmpty) _detailRow('Email', order.customerEmail),
                const Divider(height: 24),
                _detailRow('Pembayaran', _paymentStatusLabel(order.paymentStatus)),
                if (order.bankName.isNotEmpty) _detailRow('Bank', order.bankName),
                if (order.senderName.isNotEmpty) _detailRow('Pengirim', order.senderName),
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
                const Divider(height: 24),
                const Text('Produk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(i.productName)),
                      Text('${i.quantity}x'),
                      const SizedBox(width: 16),
                      Text(_formatPrice(i.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(_formatPrice(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          if (order.paymentStatus == 'verification') ...[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _orderService.approvePayment(order.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('Pembayaran #${order.orderCode} disetujui'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadOrders();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: const Text('Setujui Pembayaran'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _orderService.rejectPayment(order.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('Pembayaran #${order.orderCode} ditolak'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  _loadOrders();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(content: Text('Gagal: $e')),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Tolak Pembayaran'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showContactDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hubungi Pembeli'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(order.customerName),
            ),
            if (order.customerEmail.isNotEmpty)
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.email)),
                title: Text(order.customerEmail),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _exportCsv() {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Order Code,Tanggal,Customer,Produk,Qty,Subtotal,Status');

      for (final entry in _filteredOrders) {
        final order = entry['order'] as OrderModel;
        final items = entry['items'] as List<OrderItemModel>;
        for (final item in items) {
          buffer.writeln(
            '${_escapeCsv(order.orderCode)},'
            '${_escapeCsv(_formatDate(order.createdAt))},'
            '${_escapeCsv(order.customerName)},'
            '${_escapeCsv(item.productName)},'
            '${item.quantity},'
            '${item.subtotal},'
            '${_escapeCsv(_statusLabel(order.status))}',
          );
        }
      }

      final now = DateTime.now();
      final filename =
          'rekap_pesanan_seller_${now.year}${_pad(now.month)}${_pad(now.day)}_'
          '${_pad(now.hour)}${_pad(now.minute)}${_pad(now.second)}.csv';

      CsvExportService.export(buffer.toString(), filename);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            CsvExportService.isExportSupported
                ? 'Rekap berhasil diekspor'
                : 'Rekap disimpan ke folder temp',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengekspor rekap'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFilterDialog() {
    final tempStatuses = Set<String>.from(_filterStatuses);
    var tempStartDate = _filterStartDate;
    var tempEndDate = _filterEndDate;
    final minController = TextEditingController(text: _filterMinTotal?.toString() ?? '');
    final maxController = TextEditingController(text: _filterMaxTotal?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Pesanan'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...['pending', 'processing', 'shipped', 'completed', 'cancelled'].map((s) {
                    final labels = {
                      'pending': 'Pending',
                      'processing': 'Processing',
                      'shipped': 'Shipped',
                      'completed': 'Completed',
                      'cancelled': 'Cancelled',
                    };
                    return CheckboxListTile(
                      value: tempStatuses.contains(s),
                      onChanged: (v) {
                        setDialogState(() {
                          if (v == true) {
                            tempStatuses.add(s);
                          } else {
                            tempStatuses.remove(s);
                          }
                        });
                      },
                      title: Text(labels[s]!),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    );
                  }),
                  const Divider(),
                  const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tempStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) setDialogState(() { tempStartDate = date; });
                          },
                          child: Text(tempStartDate != null
                              ? _formatDate(tempStartDate!.toIso8601String())
                              : 'Dari Tanggal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: tempEndDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) setDialogState(() { tempEndDate = date; });
                          },
                          child: Text(tempEndDate != null
                              ? _formatDate(tempEndDate!.toIso8601String())
                              : 'Sampai Tanggal'),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text('Total Pesanan', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Minimal',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: maxController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Maksimal',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filterStatuses.clear();
                  _filterStartDate = null;
                  _filterEndDate = null;
                  _filterMinTotal = null;
                  _filterMaxTotal = null;
                  _currentPage = 1;
                });
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterStatuses = tempStatuses;
                  _filterStartDate = tempStartDate;
                  _filterEndDate = tempEndDate;
                  _filterMinTotal = int.tryParse(minController.text);
                  _filterMaxTotal = int.tryParse(maxController.text);
                  _currentPage = 1;
                });
                Navigator.pop(context);
              },
              child: const Text('Terapkan'),
            ),
          ],
        ),
      ),
    );

  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.black54),
                    overflow: TextOverflow.ellipsis),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String title, bool active, String tabKey) {
    return GestureDetector(
      onTap: () => setState(() { _activeTab = tabKey; _currentPage = 1; }),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: active
              ? const Border(
                  bottom: BorderSide(
                    color: Color(0xff1D4ED8),
                    width: 2,
                  ),
                )
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active
                ? const Color(0xff1D4ED8)
                : Colors.black54,
            fontWeight:
                active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    final displayOrders = _pagedOrders;
    if (displayOrders.isEmpty) {
      return Center(
        child: Text(
          _allOrders.isEmpty ? "Belum ada pesanan" : "Tidak ada pesanan yang sesuai filter",
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    return ListView(
      children: displayOrders.map((entry) {
        final order = entry['order'] as OrderModel;
        final items = entry['items'] as List<OrderItemModel>;
        return _orderItem(
          order: order,
          items: items,
          sellerId: _sellerId ?? '',
        );
      }).toList(),
    );
  }

  Widget _pageButton(
    String text, {
    bool active = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: active ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 6),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: active ? const Color(0xff1D4ED8) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagination() {
    if (_filteredOrders.length <= _pageSize) return const SizedBox.shrink();
    final start = (_currentPage - 1) * _pageSize + 1;
    final end = (_currentPage * _pageSize > _filteredOrders.length)
        ? _filteredOrders.length
        : _currentPage * _pageSize;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text("Menampilkan $start-$end dari ${_filteredOrders.length} pesanan"),
          const Spacer(),
          Row(
            children: _pageNumbers(),
          ),
        ],
      ),
    );
  }

  List<Widget> _pageNumbers() {
    final List<Widget> pages = [];
    if (_currentPage > 1) {
      pages.add(_pageButton("<",
          onTap: () => setState(() { _currentPage--; })));
    }
    final int total = _totalPages;
    final int current = _currentPage;
    if (total <= 7) {
      for (int i = 1; i <= total; i++) {
        pages.add(_pageButton("$i", active: i == current,
            onTap: () => setState(() { _currentPage = i; })));
      }
    } else {
      pages.add(_pageButton("1", active: 1 == current,
          onTap: () => setState(() { _currentPage = 1; })));
      if (current > 3) {
        pages.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text("...")));
      }
      final int start = current > 3 ? current - 1 : 2;
      final int end = current < total - 2 ? current + 1 : total - 1;
      for (int i = start; i <= end; i++) {
        pages.add(_pageButton("$i", active: i == current,
            onTap: () => setState(() { _currentPage = i; })));
      }
      if (current < total - 2) {
        pages.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text("...")));
      }
      pages.add(_pageButton("$total", active: total == current,
          onTap: () => setState(() { _currentPage = total; })));
    }
    if (_currentPage < total) {
      pages.add(_pageButton(">",
          onTap: () => setState(() { _currentPage++; })));
    }
    return pages;
  }
}

class _StatusButton extends StatelessWidget {
  final OrderModel order;
  final String sellerId;
  final VoidCallback? onStatusChanged;

  const _StatusButton({required this.order, required this.sellerId, this.onStatusChanged});

  String? _nextStatus(String current) {
    switch (current.toLowerCase()) {
      case 'pending':
        return 'processing';
      case 'processing':
        return 'shipped';
      case 'shipped':
        return 'completed';
      default:
        return null;
    }
  }

  String _nextLabel(String current) {
    switch (current.toLowerCase()) {
      case 'pending':
        return 'Proses';
      case 'processing':
        return 'Kirim';
      case 'shipped':
        return 'Selesaikan';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextStatus(order.status);
    if (next == null) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
        ),
        onPressed: null,
        child: const Text(
          'Selesai',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff1D4ED8),
      ),
      onPressed: () async {
        try {
          await OrderServiceAppwrite().updateOrderStatus(
            orderId: order.id,
            status: next,
            sellerId: sellerId,
          );
          if (!context.mounted) return;
          onStatusChanged?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status berhasil diubah'),
              backgroundColor: Colors.green,
            ),
          );
        } on AppwriteException catch (e) {
          if (!context.mounted) return;
          debugPrint(
            'ORDER STATUS ERROR | '
            'code=${e.code} | '
            'type=${e.type} | '
            'message=${e.message}',
          );
          String message = e.message ?? 'Gagal mengubah status';
          if (e.code == 403) {
            message = 'Anda tidak memiliki akses untuk mengubah pesanan ini';
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
          onStatusChanged?.call();
        } catch (e) {
          if (!context.mounted) return;
          debugPrint('ORDER STATUS UNEXPECTED ERROR: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Text(
        _nextLabel(order.status),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
