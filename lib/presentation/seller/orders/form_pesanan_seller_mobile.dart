import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';

import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/order_service_appwrite.dart';
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
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  String? _sellerId;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<List<Map<String, dynamic>>> _loadOrders() async {
    final account = await AuthServiceAppwrite().getCurrentUser();
    _sellerId = account.$id;
    return _orderService.getSellerOrdersWithDetails(account.$id);
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
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pesanan",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Kelola pesanan dari pelanggan Anda",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _tab("Semua", true),
                        const SizedBox(width: 8),
                        _tab("Perlu Diproses", false),
                        const SizedBox(width: 8),
                        _tab("Dikirim", false),
                        const SizedBox(width: 8),
                        _tab("Selesai", false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          "Gagal memuat pesanan:\n${snapshot.error}",
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final orders = snapshot.data ?? [];

                  if (orders.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Belum ada pesanan",
                            style: TextStyle(
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
                        final order =
                            entry['order'] as OrderModel;
                        final items =
                            entry['items'] as List<OrderItemModel>;
                        return _OrderCard(
                          order: order,
                          items: items,
                          sellerId: _sellerId ?? '',
                          formatPrice: _formatPrice,
                          formatDate: _formatDate,
                          statusColor: _statusColor,
                          statusLabel: _statusLabel,
                        );
                      }),
                      const SizedBox(height: 100),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _tab(String title, bool active) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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

  const _OrderCard({
    required this.order,
    required this.items,
    required this.sellerId,
    required this.formatPrice,
    required this.formatDate,
    required this.statusColor,
    required this.statusLabel,
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
            _StatusActions(order: order, sellerId: sellerId),
          ],
        ),
      ),
    );
  }
}

class _StatusActions extends StatelessWidget {
  final OrderModel order;
  final String sellerId;

  const _StatusActions({required this.order, required this.sellerId});

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
