//lib/presentation/customer/orders/pesanan_customer_mobile.dart

import 'package:flutter/material.dart';

import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/order_service_appwrite.dart';
import '../../../data/models/order_model.dart';
import 'detail_pesanan_customer.dart';

class PesananCustomerMobile extends StatefulWidget {
  const PesananCustomerMobile({super.key});

  @override
  State<PesananCustomerMobile> createState() => PesananCustomerMobileState();
}

class PesananCustomerMobileState
    extends State<PesananCustomerMobile> {
  final OrderServiceAppwrite _orderService = OrderServiceAppwrite();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;
  String _activeTab = 'semua';

  List<OrderModel> get _filteredOrders {
    if (_activeTab == 'semua') return _orders;
    return _orders.where((o) {
      switch (_activeTab) {
        case 'berlangsung':
          return ['pending', 'processing'].contains(o.status.toLowerCase());
        case 'dikirim':
          return o.status.toLowerCase() == 'shipped';
        case 'selesai':
          return ['completed', 'delivered'].contains(o.status.toLowerCase());
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

  String _formatPrice(int price) {
    final p = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                "Pesanan Saya",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Lacak dan kelola semua transaksi Anda di sini.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection:
                      Axis.horizontal,
                  children: [
                    _tab("Semua", _activeTab == 'semua', 'semua'),
                    _tab("Berlangsung", _activeTab == 'berlangsung', 'berlangsung'),
                    _tab("Dikirim", _activeTab == 'dikirim', 'dikirim'),
                    _tab("Selesai", _activeTab == 'selesai', 'selesai'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _error != null
                      ? SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              "Gagal memuat pesanan: $_error",
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _filteredOrders.isEmpty
                          ? const SizedBox(
                              height: 200,
                              child: Center(
                                child: Text(
                                  "Belum ada pesanan",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: _filteredOrders
                                  .map((order) =>
                                      _orderCard(order))
                                  .toList(),
                            ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String text, bool active, String tabKey) {
    return GestureDetector(
      onTap: () => setState(() => _activeTab = tabKey),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
        ),
        decoration: BoxDecoration(
          color: active
              ? Colors.white
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(25),
          border: Border.all(
            color: active
                ? const Color(0xff2563EB)
                : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: active
                  ? const Color(0xff2563EB)
                  : Colors.black54,
              fontWeight:
                  active ? FontWeight.bold : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderCard(OrderModel order) {
    final color = _statusColor(order.status);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPesananCustomer(orderId: order.id),
          ),
        );
        _loadOrders();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  order.status == 'completed' ||
                          order.status ==
                              'delivered'
                      ? Icons.check_circle_outline
                      : Icons.local_shipping,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 6),
                Text(
                  order.status,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  order.orderCode,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  size: 36,
                  color: Colors.black54,
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
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(order.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatPrice(
                            order.totalAmount),
                        style: const TextStyle(
                          color:
                              Color(0xff2563EB),
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
}
