//lib/presentation/seller/orders/form_pesanan_seller_web.dart

import 'package:flutter/material.dart';

import 'package:appwrite/appwrite.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/order_service_appwrite.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/order_item_model.dart';

class FormPesananSellerWeb extends StatefulWidget {
  const FormPesananSellerWeb({super.key});

  @override
  State<FormPesananSellerWeb> createState() =>
      _FormPesananSellerWebState();
}

class _FormPesananSellerWebState
    extends State<FormPesananSellerWeb> {
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
                const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Andi Setiawan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Verified Merchant",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150",
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
                  onPressed: () {},
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
                    "24 Pesanan",
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    Icons.local_shipping_outlined,
                    "Sedang Dikirim",
                    "12 Pesanan",
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statCard(
                    Icons.payments_outlined,
                    "Total Penjualan",
                    "Rp 12.450.000",
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
                          _tab("Semua", true),
                          _tab(
                            "Perlu Diproses",
                            false,
                          ),
                          _tab("Dikirim", false),
                          _tab("Selesai", false),
                          _tab("Dibatalkan", false),
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
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration:
                                BoxDecoration(
                              border: Border.all(
                                color: Colors
                                    .grey.shade300,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          10),
                            ),
                            child: const Row(
                              children: [
                                Text("Urutkan: Terbaru"),
                                SizedBox(width: 5),
                                Icon(Icons
                                    .keyboard_arrow_down),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding:
                                const EdgeInsets.all(
                                    14),
                            decoration:
                                BoxDecoration(
                              border: Border.all(
                                color: Colors
                                    .grey.shade300,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          10),
                            ),
                            child: const Icon(
                              Icons.tune,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child:
                          FutureBuilder<
                              List<
                                  Map<String,
                                      dynamic>>>(
                        future: _ordersFuture,
                        builder: (context,
                            snapshot) {
                          if (snapshot
                                  .connectionState ==
                              ConnectionState
                                  .waiting) {
                            return const Center(
                              child:
                                  CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets
                                        .all(32),
                                child: Text(
                                  "Gagal memuat pesanan:\n${snapshot.error}",
                                  style: const TextStyle(
                                      color:
                                          Colors
                                              .red),
                                  textAlign:
                                      TextAlign
                                          .center,
                                ),
                              ),
                            );
                          }

                          final orders =
                              snapshot.data ?? [];

                          if (orders.isEmpty) {
                            return const Center(
                              child: Text(
                                "Belum ada pesanan",
                                style: TextStyle(
                                  color:
                                      Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          return ListView(
                            children: orders
                                .map((entry) {
                              final order = entry[
                                      'order']
                                  as OrderModel;
                              final items =
                                  entry['items']
                                      as List<
                                          OrderItemModel>;
                              return _orderItem(
                                order: order,
                                items: items,
                                sellerId: _sellerId ?? '',
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text(
                            "Menampilkan 1-10 dari 192 pesanan",
                          ),
                          const Spacer(),
                          _pageButton("<"),
                          _pageButton(
                            "1",
                            active: true,
                          ),
                          _pageButton("2"),
                          _pageButton("3"),
                          const Padding(
                            padding:
                                EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            child: Text("..."),
                          ),
                          _pageButton("13"),
                          _pageButton(">"),
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
      trailing: SizedBox(
        width: 170,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(sellerSubtotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1D4ED8),
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
            _StatusButton(order: order, sellerId: sellerId),
            const SizedBox(width: 8),
            const Icon(Icons.more_vert),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      height: 90,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.black54)),
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

  Widget _tab(String title, bool active) {
    return Container(
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
    );
  }

  Widget _pageButton(
    String text, {
    bool active = false,
  }) {

    return Container(
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
    );
  }
}

class _StatusButton extends StatelessWidget {
  final OrderModel order;
  final String sellerId;

  const _StatusButton({required this.order, required this.sellerId});

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status berhasil diubah'),
              backgroundColor: Colors.green,
            ),
          );
        } on AppwriteException catch (e) {
          if (!context.mounted) return;
          String message = 'Gagal mengubah status';
          if (e.code == 400) {
            message = 'Transisi status tidak valid';
          } else if (e.code == 403) {
            message = 'Anda tidak memiliki akses untuk mengubah pesanan ini';
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        } catch (e) {
          if (!context.mounted) return;
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
