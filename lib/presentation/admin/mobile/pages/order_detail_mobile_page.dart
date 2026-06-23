import 'package:flutter/material.dart';

import '../../../../core/services/order_service_appwrite.dart';
import '../../../../core/services/storage_service_appwrite.dart';
import '../../../../data/models/order_model.dart';

class OrderDetailMobilePage extends StatefulWidget {
  final String orderId;

  const OrderDetailMobilePage({super.key, required this.orderId});

  @override
  State<OrderDetailMobilePage> createState() => _OrderDetailMobilePageState();
}

class _OrderDetailMobilePageState extends State<OrderDetailMobilePage> {
  final OrderServiceAppwrite _orderService = OrderServiceAppwrite();
  final StorageServiceAppwrite _storageService = StorageServiceAppwrite();

  OrderModel? _order;
  bool _loading = true;
  String? _error;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final order = await _orderService.getOrderById(widget.orderId);
      if (!mounted) return;
      if (order == null) {
        setState(() {
          _error = 'Pesanan tidak ditemukan';
          _loading = false;
        });
        return;
      }
      setState(() {
        _order = order;
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

  Future<void> _approvePayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menyetujui pembayaran?'),
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
    if (confirmed != true) return;

    setState(() => _actionLoading = true);
    try {
      await _orderService.approvePayment(widget.orderId);
      await _loadOrder();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyetujui pembayaran: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Future<void> _rejectPayment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin menolak pembayaran?'),
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

    setState(() => _actionLoading = true);
    try {
      await _orderService.rejectPayment(widget.orderId);
      await _loadOrder();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran ditolak'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menolak pembayaran: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  String _formatPrice(int price) {
    if (price >= 1000000) {
      return 'Rp ${(price / 1000000).toStringAsFixed(1)} JT';
    }
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
      return '${dt.day} ${months[dt.month]} ${dt.year}, '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  Color _paymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verification':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'unpaid':
      default:
        return Colors.grey;
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'verification':
        return 'Verification';
      case 'paid':
        return 'Paid';
      case 'rejected':
        return 'Rejected';
      case 'unpaid':
        return 'Unpaid';
      default:
        return status;
    }
  }

  Color _orderStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return const Color(0xff2563EB);
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _orderStatusLabel(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: Text(
          _order?.orderCode ?? 'Detail Pesanan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                onPressed: _loadOrder,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final order = _order!;

    return RefreshIndicator(
      onRefresh: _loadOrder,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoCard('Informasi Pelanggan', [
              _infoRow(Icons.person, 'Nama', order.customerName),
              _infoRow(Icons.email_outlined, 'Email', order.customerEmail),
              if (order.phone.isNotEmpty)
                _infoRow(Icons.phone, 'Telepon', order.phone),
              if (order.address.isNotEmpty)
                _infoRow(Icons.home, 'Alamat', order.address),
            ]),
            const SizedBox(height: 12),
            _buildInfoCard('Informasi Pesanan', [
              _infoRow(Icons.receipt, 'Kode Order', order.orderCode),
              _infoRow(
                Icons.inventory_2,
                'Status Order',
                _orderStatusLabel(order.status),
                valueColor: _orderStatusColor(order.status),
              ),
              _infoRow(
                Icons.payment,
                'Status Pembayaran',
                _paymentStatusLabel(order.paymentStatus),
                valueColor: _paymentStatusColor(order.paymentStatus),
              ),
              _infoRow(Icons.account_balance_wallet, 'Total Belanja',
                  _formatPrice(order.totalAmount)),
              _infoRow(Icons.receipt_long, 'Biaya Layanan',
                  'Rp ${order.serviceFee}'),
              if (order.notes.isNotEmpty)
                _infoRow(Icons.notes, 'Catatan', order.notes),
              _infoRow(Icons.access_time, 'Tanggal',
                  _formatDate(order.createdAt)),
            ]),
            const SizedBox(height: 12),
            _buildPaymentProofSection(order),
            if (order.paymentStatus.toLowerCase() == 'verification') ...[
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

  Widget _buildPaymentProofSection(OrderModel order) {
    final hasProof = order.paymentReceiptImage.isNotEmpty;

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
            'Bukti Transfer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 12),
          if (hasProof)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _storageService.getImageUrl(order.paymentReceiptImage),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image,
                              size: 32, color: Colors.red.shade300),
                          const SizedBox(height: 4),
                          Text(
                            'Gagal memuat gambar',
                            style: TextStyle(
                                fontSize: 12, color: Colors.red.shade400),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade200, style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_outlined,
                        size: 28, color: Colors.grey.shade400),
                    const SizedBox(height: 4),
                    Text(
                      'Belum ada bukti pembayaran',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade500),
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
              onPressed: _actionLoading ? null : _rejectPayment,
              icon: _actionLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.close),
              label: const Text('Tolak Pembayaran'),
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
              onPressed: _actionLoading ? null : _approvePayment,
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
              label: const Text('Setujui Pembayaran'),
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
