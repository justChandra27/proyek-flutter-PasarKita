import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/order_service_appwrite.dart';
import '../../../core/services/storage_service_appwrite.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/order_item_model.dart';
import '../profile/profile_seller_mobile.dart';

class FormPesananSellerMobile extends StatefulWidget {
  const FormPesananSellerMobile({super.key});

  @override
  State<FormPesananSellerMobile> createState() =>
      _FormPesananSellerMobileState();
}

class _FormPesananSellerMobileState
    extends State<FormPesananSellerMobile> {
  final OrderServiceAppwrite _orderService = OrderServiceAppwrite();
  String? _sellerId;

  List<Map<String, dynamic>> _allOrders = [];
  bool _isLoading = true;
  String? _error;

  String _activeTab = 'semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'terbaru';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() { _searchQuery = _searchController.text; });
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
      final account = await AuthServiceAppwrite().getCurrentUser();
      _sellerId = account.$id;
      final orders = await _orderService.getSellerOrdersWithDetails(account.$id);
      if (mounted) setState(() { _allOrders = orders; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
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

      if (_activeTab != 'semua') {
        if (order.status.toLowerCase() != _activeTab) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesSearch =
            order.orderCode.toLowerCase().contains(q) ||
            order.customerName.toLowerCase().contains(q) ||
            items.any((i) => i.productName.toLowerCase().contains(q));
        if (!matchesSearch) return false;
      }

      return true;
    }).toList();

    switch (_sortBy) {
      case 'terlama':
        result.sort((a, b) => (a['order'] as OrderModel).createdAt
            .compareTo((b['order'] as OrderModel).createdAt));
        break;
      case 'total_tertinggi':
        result.sort((a, b) => _subtotal(b).compareTo(_subtotal(a)));
        break;
      case 'total_terendah':
        result.sort((a, b) => _subtotal(a).compareTo(_subtotal(b)));
        break;
      default:
        result.sort((a, b) => (b['order'] as OrderModel).createdAt
            .compareTo((a['order'] as OrderModel).createdAt));
    }

    return result;
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xff1E40AF);
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return const Color(0xff2563EB);
      case 'delivered':
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
        return 'Pesanan Baru';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
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

  void _viewReceipt(BuildContext context, String fileId) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "PasarKita",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2563EB),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SellerEditProfileMobile(),
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(0xff2563EB),
                          child: Text(
                            "S",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pesanan",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Kelola pesanan dari pelanggan Anda",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        // SEARCH FIELD
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Cari pesanan...",
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: const Color(0xffF5F7FB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // TABS + SORT
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _tab("Semua", _activeTab == 'semua', 'semua'),
                              const SizedBox(width: 8),
                              _tab("Perlu Diproses", _activeTab == 'pending', 'pending'),
                              const SizedBox(width: 8),
                              _tab("Dikirim", _activeTab == 'shipped', 'shipped'),
                              const SizedBox(width: 8),
                              _tab("Selesai", _activeTab == 'completed', 'completed'),
                              const SizedBox(width: 8),
                              _tab("Dibatalkan", _activeTab == 'cancelled', 'cancelled'),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                initialValue: _sortBy,
                                onSelected: (value) =>
                                    setState(() { _sortBy = value; }),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(value: 'terbaru', child: Text("Terbaru")),
                                  const PopupMenuItem(value: 'terlama', child: Text("Terlama")),
                                  const PopupMenuItem(value: 'total_tertinggi', child: Text("Total Tertinggi")),
                                  const PopupMenuItem(value: 'total_terendah', child: Text("Total Terendah")),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xffDBEAFE),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.sort, size: 18),
                                      SizedBox(width: 4),
                                      Text("Urutkan", style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // CONTENT
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            "Gagal memuat pesanan:\n$_error",
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final orders = _filteredOrders;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _allOrders.isEmpty ? Icons.receipt_long_outlined : Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _allOrders.isEmpty ? "Belum ada pesanan" : "Tidak ada pesanan yang sesuai",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...orders.map((entry) {
          final order = entry['order'] as OrderModel;
          final items = entry['items'] as List<OrderItemModel>;
          return _OrderCard(
            order: order,
            items: items,
            sellerId: _sellerId ?? '',
            formatPrice: _formatPrice,
            formatDate: _formatDate,
            statusColor: _statusColor,
            statusLabel: _statusLabel,
            onDetail: () => _showDetailBottomSheet(order, items),
            onContact: () => _showContactBottomSheet(order),
            onStatusChanged: () => _loadOrders(),
          );
        }),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _tab(String title, bool active, String tabKey) {
    return GestureDetector(
      onTap: () => setState(() { _activeTab = tabKey; }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xff1E40AF)
              : const Color(0xffDBEAFE),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : Colors.black54,
            fontWeight: active ? FontWeight.bold : null,
          ),
        ),
      ),
    );
  }

  void _showDetailBottomSheet(OrderModel order, List<OrderItemModel> items) {
    final total = items.fold<int>(0, (s, i) => s + i.subtotal);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Detail Pesanan",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // Order Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffF5F7FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _infoRow("Kode Pesanan", order.orderCode),
                        _infoRow("Status", order.status),
                        _infoRow("Tanggal", _formatDate(order.createdAt)),
                        _infoRow("Customer", order.customerName),
                        if (order.customerEmail.isNotEmpty)
                          _infoRow("Email", order.customerEmail),
                        _infoRow("Pembayaran", _paymentStatusLabel(order.paymentStatus)),
                        if (order.bankName.isNotEmpty)
                          _infoRow("Bank", order.bankName),
                        if (order.senderName.isNotEmpty)
                          _infoRow("Pengirim", order.senderName),
                        if (order.notes.isNotEmpty)
                          _infoRow("Catatan", order.notes),
                        if (order.paymentReceiptImage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TextButton.icon(
                              onPressed: () => _viewReceipt(context, order.paymentReceiptImage),
                              icon: const Icon(Icons.image, size: 18),
                              label: const Text('Lihat Bukti Transfer'),
                            ),
                          ),
                        if (order.receiptPdfFileId.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: TextButton.icon(
                              onPressed: () => _viewReceiptPdf(order.receiptPdfFileId),
                              icon: const Icon(Icons.description, size: 18),
                              label: const Text('Lihat Struk'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Items Header
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Produk",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        _formatPrice(total),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  // Items
                  ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text("${item.quantity} x ${_formatPrice(item.price)}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ),
                        Text(
                          _formatPrice(item.subtotal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
                  const Divider(),
                  // Total
                  Row(
                    children: [
                      const Expanded(
                        child: Text("Total", style: TextStyle(fontSize: 16)),
                      ),
                      Text(
                        _formatPrice(total),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1E40AF),
                        ),
                      ),
                    ],
                  ),
                  if (order.paymentStatus == 'verification') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                await _orderService.approvePayment(order.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Pembayaran #${order.orderCode} disetujui'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _loadOrders();
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal: $e')),
                                );
                              }
                            },
                            child: const Text('Setujui Pembayaran'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                await _orderService.rejectPayment(order.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Pembayaran #${order.orderCode} ditolak'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                _loadOrders();
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal: $e')),
                                );
                              }
                            },
                            child: const Text('Tolak Pembayaran'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showContactBottomSheet(OrderModel order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (order.customerEmail.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            order.customerEmail,
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  static Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final List<OrderItemModel> items;
  final String sellerId;
  final String Function(int) formatPrice;
  final String Function(String) formatDate;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;
  final VoidCallback? onDetail;
  final VoidCallback? onContact;
  final VoidCallback? onStatusChanged;

  const _OrderCard({
    required this.order,
    required this.items,
    required this.sellerId,
    required this.formatPrice,
    required this.formatDate,
    required this.statusColor,
    required this.statusLabel,
    this.onDetail,
    this.onContact,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColor(order.status);
    final sellerSubtotal =
        items.fold<int>(0, (sum, i) => sum + i.subtotal);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: order.status.toLowerCase() == 'pending'
              ? const Color(0xff1E40AF)
              : Colors.grey.shade200,
          width: order.status.toLowerCase() == 'pending' ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.orderCode,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'detail') onDetail?.call();
                    if (value == 'contact') onContact?.call();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'detail', child: ListTile(
                      leading: Icon(Icons.receipt_long),
                      title: Text("Lihat Detail"),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    )),
                    const PopupMenuItem(value: 'contact', child: ListTile(
                      leading: Icon(Icons.contact_phone),
                      title: Text("Hubungi Pembeli"),
                      contentPadding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    )),
                  ],
                  child: const Icon(Icons.more_vert, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel(order.status),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.customerName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  formatDate(order.createdAt),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${item.quantity} x ${formatPrice(item.price)}",
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Subtotal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Text(
                  formatPrice(sellerSubtotal),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E40AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _StatusActions(order: order, sellerId: sellerId, onStatusChanged: onStatusChanged),
          ],
        ),
      ),
    );
  }
}

class _StatusActions extends StatelessWidget {
  final OrderModel order;
  final String sellerId;
  final VoidCallback? onStatusChanged;

  const _StatusActions({required this.order, required this.sellerId, this.onStatusChanged});

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
        return 'Proses Pesanan';
      case 'processing':
        return 'Kirim Pesanan';
      case 'shipped':
        return 'Selesaikan Pesanan';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final next = _nextStatus(order.status);
    if (next == null) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff1E40AF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
                content: Text('Status berhasil diubah ke ${_nextLabel(order.status)}'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            if (!context.mounted) return;
            String message = 'Gagal mengubah status';
            if (e is AppwriteException) {
              if (e.code == 400) {
                message = 'Transisi status tidak valid';
              } else if (e.code == 403) {
                message = 'Anda tidak memiliki akses untuk mengubah pesanan ini';
              }
            }
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Text(_nextLabel(order.status)),
      ),
    );
  }
}
