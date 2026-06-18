//lib/presentation/customer/orders/pesanan_customer_web.dart

import 'package:flutter/material.dart';

import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/order_service_appwrite.dart';
import '../../../data/models/order_model.dart';
import 'detail_pesanan_customer.dart';

class PesananCustomerWeb extends StatefulWidget {
  const PesananCustomerWeb({super.key});

  @override
  State<PesananCustomerWeb> createState() => PesananCustomerWebState();
}

class PesananCustomerWebState
    extends State<PesananCustomerWeb> {
  final OrderServiceAppwrite _orderService = OrderServiceAppwrite();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _activeTab = 'semua';

  List<OrderModel> get _filteredOrders {
    if (_activeTab == 'semua') return _orders;
    return _orders.where((o) {
      switch (_activeTab) {
        case 'berjalan':
          return ['pending', 'processing', 'shipped'].contains(o.status.toLowerCase());
        case 'selesai':
          return ['completed', 'delivered'].contains(o.status.toLowerCase());
        case 'dibatalkan':
          return o.status.toLowerCase() == 'cancelled';
        default:
          return true;
      }
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void refresh() => _loadOrders();

  Future<void> _loadOrders() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final account = await AuthServiceAppwrite().getCurrentUser();
      final orders = await _orderService.getOrdersByCustomer(account.$id);
      if (mounted) setState(() { _orders = orders; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Cari pesanan...",
                        prefixIcon:
                            const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.notifications_none,
                  color: Colors.black54,
                ),
                const SizedBox(width: 16),
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Pesanan Saya",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // TAB FILTER
            Row(
              children: [
                _tabButton("Semua", _activeTab == 'semua', 'semua'),
                const SizedBox(width: 10),
                _tabButton("Berjalan", _activeTab == 'berjalan', 'berjalan'),
                const SizedBox(width: 10),
                _tabButton("Selesai", _activeTab == 'selesai', 'selesai'),
                const SizedBox(width: 10),
                _tabButton("Dibatalkan", _activeTab == 'dibatalkan', 'dibatalkan'),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            "Gagal memuat pesanan: $_error",
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _filteredOrders.isEmpty
                          ? const Center(
                              child: Text(
                                "Belum ada pesanan",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView(
                              children: _filteredOrders
                                  .map(
                                    (order) => Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _OrderCard(order: order, onDetailClosed: refresh),
                                    ),
                                  )
                                  .toList(),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String text, bool active, String tabKey) {
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tabKey),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xff2563EB)
              : const Color(0xffDBEAFE),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active
                ? Colors.white
                : Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onDetailClosed;

  const _OrderCard({required this.order, this.onDetailClosed});

  Color _paymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'unpaid':
        return Colors.orange;
      case 'verification':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'unpaid':
        return 'Menunggu Pembayaran';
      case 'verification':
        return 'Menunggu Verifikasi';
      case 'paid':
        return 'Pembayaran Berhasil';
      case 'rejected':
        return 'Bukti Transfer Ditolak';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
      case 'shipped':
        return const Color(0xff2563EB);
      case 'completed':
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPesananCustomer(orderId: order.id),
          ),
        );
        onDetailClosed?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    statusColor.withValues(alpha: .15),
                child: Icon(
                  order.status == 'completed' ||
                          order.status == 'delivered'
                      ? Icons.check_circle
                      : Icons.local_shipping,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      order.status,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(order.createdAt),
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(order.totalAmount),
                    style: const TextStyle(
                      color: Color(0xff2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (order.paymentStatus.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _paymentStatusColor(order.paymentStatus).withValues(alpha: .15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _paymentStatusLabel(order.paymentStatus),
                style: TextStyle(
                  color: _paymentStatusColor(order.paymentStatus),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 40,
                  color: Colors.black54,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.orderCode,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(order.createdAt),
                        style: const TextStyle(
                          color: Colors.black54,
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
    );
  }
}
