import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../core/services/order_service_appwrite.dart';
import '../../../core/services/review_service_appwrite.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/order_item_model.dart';

class DetailPesananCustomer extends StatefulWidget {
  final String orderId;

  const DetailPesananCustomer({super.key, required this.orderId});

  @override
  State<DetailPesananCustomer> createState() => _DetailPesananCustomerState();
}

class _DetailPesananCustomerState extends State<DetailPesananCustomer> {
  final _orderService = OrderServiceAppwrite();
  final _reviewService = ReviewServiceAppwrite();
  late Future<Map<String, dynamic>> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _loadDetail();
  }

  Future<Map<String, dynamic>> _loadDetail() async {
    final order = await _orderService.getOrderById(widget.orderId);
    final items = await _orderService.getOrderItems(widget.orderId);
    return {'order': order, 'items': items};
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
        return Colors.orange;
      case 'processing':
        return const Color(0xff2563EB);
      case 'shipped':
        return Colors.blue;
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
        return 'Menunggu Diproses';
      case 'processing':
        return 'Sedang Diproses';
      case 'shipped':
        return 'Dalam Pengiriman';
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
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Gagal memuat detail pesanan',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final order = snapshot.data!['order'] as OrderModel?;
          final items = snapshot.data!['items'] as List<OrderItemModel>? ?? [];

          if (order == null) {
            return const Center(child: Text('Pesanan tidak ditemukan'));
          }

          final statusColor = _statusColor(order.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusHeader(order, statusColor),
                const SizedBox(height: 16),
                _infoCard(
                  icon: Icons.receipt_long_outlined,
                  children: [
                    _infoRow('Kode Pesanan', order.orderCode),
                    _infoRow('Tanggal', _formatDate(order.createdAt)),
                    _infoRow('Status', _statusLabel(order.status)),
                  ],
                ),
                const SizedBox(height: 16),
                _infoCard(
                  icon: Icons.person_outline,
                  children: [
                    _infoRow('Nama', order.customerName),
                    _infoRow('Alamat', order.address),
                  ],
                ),
                const SizedBox(height: 16),
                _infoCard(
                  icon: Icons.payment_outlined,
                  children: [
                    _infoRow('Metode', order.paymentMethod),
                    _infoRow('Pembayaran', order.paymentStatus),
                  ],
                ),
                const SizedBox(height: 16),
                _productCard(order, items),
                const SizedBox(height: 16),
                _totalCard(order),
                const SizedBox(height: 16),
                _timelineCard(order),
                if (order.status == 'pending') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmCancel(order),
                      icon: const Icon(Icons.cancel_outlined,
                          color: Colors.red),
                      label: const Text('Batalkan Pesanan',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusHeader(OrderModel order, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Icon(
            order.status == 'completed'
                ? Icons.check_circle
                : order.status == 'cancelled'
                    ? Icons.cancel
                    : Icons.local_shipping,
            color: color,
            size: 40,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _statusLabel(order.status),
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.orderCode,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xff2563EB)),
              const SizedBox(width: 8),
              Text(
                'Informasi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(OrderModel order, List<OrderItemModel> items) {
    final isCompleted = order.status.toLowerCase() == 'completed';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  size: 20, color: Color(0xff2563EB)),
              const SizedBox(width: 8),
              Text(
                'Produk Dibeli',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: item.imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    item.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(
                                      Icons.inventory_2_outlined,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.inventory_2_outlined,
                                  color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              if (item.color.isNotEmpty ||
                                  item.size.isNotEmpty)
                                Text(
                                  [
                                    if (item.color.isNotEmpty) item.color,
                                    if (item.size.isNotEmpty) item.size,
                                  ].join(' / '),
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              Text(
                                '${item.quantity} x ${_formatPrice(item.price)}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatPrice(item.subtotal),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2563EB),
                          ),
                        ),
                      ],
                    ),
                    if (isCompleted)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 60),
                        child: FutureBuilder<bool>(
                          future: _reviewService.hasReviewed(
                            productId: item.productId,
                            orderId: widget.orderId,
                            userId: order.customerId,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              );
                            }
                            if (snapshot.data == true) {
                              return const Text(
                                '✓ Sudah diulas',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }
                            return TextButton.icon(
                              onPressed: () => _showReviewForm(
                                productId: item.productId,
                                productName: item.productName,
                                orderId: widget.orderId,
                                userId: order.customerId,
                                userName: order.customerName,
                              ),
                              icon: const Icon(Icons.star_border, size: 18),
                              label: const Text('Beri Ulasan'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xff2563EB),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showReviewForm({
    required String productId,
    required String productName,
    required String orderId,
    required String userId,
    required String userName,
  }) {
    int rating = 5;
    final commentController = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Beri Ulasan'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  const Text('Rating',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      final starValue = i + 1;
                      return IconButton(
                        icon: Icon(
                          starValue <= rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () =>
                            setDialogState(() => rating = starValue),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Komentar (opsional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (submitting)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: submitting
                  ? null
                  : () async {
                      setDialogState(() => submitting = true);
                      try {
                        await _reviewService.createReview(
                          productId: productId,
                          orderId: orderId,
                          userId: userId,
                          userName: userName,
                          rating: rating,
                          comment: commentController.text.trim().isEmpty
                              ? null
                              : commentController.text.trim(),
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                        if (mounted) {
                          _detailFuture = _loadDetail();
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Ulasan berhasil dikirim')),
                          );
                        }
                      } on AppwriteException catch (e) {
                        if (e.type == 'duplicate_review') {
                          if (ctx.mounted) {
                            setDialogState(() => submitting = false);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Anda sudah memberikan ulasan untuk produk ini',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        } else {
                          if (ctx.mounted) {
                            setDialogState(() => submitting = false);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal: ${e.message ?? e.type}',
                                ),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (ctx.mounted) {
                          setDialogState(() => submitting = false);
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal: $e')),
                          );
                        }
                      }
                    },
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalCard(OrderModel order) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            _formatPrice(order.totalAmount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color(0xff2563EB),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Pesanan'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan pesanan ini? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await OrderServiceAppwrite().updateOrderStatus(
        orderId: order.id,
        status: 'cancelled',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dibatalkan'),
          backgroundColor: Colors.green,
        ),
      );
      _detailFuture = _loadDetail();
      setState(() {});
    } on AppwriteException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _timelineCard(OrderModel order) {
    final isCancelled = order.status.toLowerCase() == 'cancelled';
    final status = order.status.toLowerCase();

    final steps = [
      {'label': 'Pesanan Dibuat', 'key': 'pending'},
      {'label': 'Pesanan Diproses', 'key': 'processing'},
      {'label': 'Dikirim', 'key': 'shipped'},
      {'label': 'Pesanan Selesai', 'key': 'completed'},
    ];

    final statusOrder = ['pending', 'processing', 'shipped', 'completed'];
    final currentIndex = statusOrder.indexOf(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, size: 20, color: Color(0xff2563EB)),
              const SizedBox(width: 8),
              Text(
                isCancelled ? 'Pesanan Dibatalkan' : 'Status Pesanan',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final done = !isCancelled && currentIndex >= i;
            final isLast = i == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: done
                            ? const Color(0xff2563EB)
                            : isCancelled && i == 0
                                ? Colors.red
                                : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: done
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : (isCancelled && i == 0
                              ? const Icon(Icons.close,
                                  size: 14, color: Colors.white)
                              : null),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        color: done
                            ? const Color(0xff2563EB)
                            : Colors.grey.shade300,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                    child: Text(
                      step['label'] as String,
                      style: TextStyle(
                        fontWeight:
                            done ? FontWeight.w600 : FontWeight.normal,
                        color: done
                            ? Colors.black87
                            : (isCancelled ? Colors.red.shade300 : Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
