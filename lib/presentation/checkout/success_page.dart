import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';

import '../../core/appwrite/appwrite_config.dart';
import '../../core/appwrite/appwrite_service.dart';
import '../../core/services/order_service_appwrite.dart';
import '../../core/services/storage_service_appwrite.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_item_model.dart';
import '../customer/customer_page.dart';

class SuccessPage extends StatefulWidget {
  final String orderId;
  final String customerName;
  final String address;
  final String paymentMethod;
  final int totalAmount;
  final List<Map<String, dynamic>> items;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountName;
  final String? senderName;

  const SuccessPage({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.address,
    required this.paymentMethod,
    required this.totalAmount,
    required this.items,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountName,
    this.senderName,
  });

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  late Future<Map<String, dynamic>> _orderFuture;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _orderFuture = _loadOrder();
  }

  Future<Map<String, dynamic>> _loadOrder() async {
    final orderService = OrderServiceAppwrite();
    final databases = AppwriteService.databases;

    final doc = await databases.getDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.ordersCollectionId,
      documentId: widget.orderId,
    );
    final order = OrderModel.fromMap(doc.$id, doc.data);
    final items = await orderService.getOrderItems(widget.orderId);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const SizedBox(),
        title: const Text(
          'Pembayaran Berhasil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat detail pesanan\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text('Kembali ke Toko'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          final order = data['order'] as OrderModel;
          final items = data['items'] as List<OrderItemModel>;

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Pembayaran Berhasil',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      order.orderCode,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _infoCard(
                      icon: Icons.person_outline,
                      children: [
                        _infoRow('Nama', widget.customerName),
                        _infoRow('Alamat', widget.address),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _infoCard(
                      icon: Icons.payment_outlined,
                      children: [
                        _infoRow(
                          'Metode Pembayaran',
                          widget.paymentMethod,
                        ),
                        if (widget.bankName != null)
                          _infoRow('Bank Tujuan', widget.bankName!),
                        if (widget.bankAccountNumber != null)
                          _infoRow('No. Rekening', widget.bankAccountNumber!),
                        if (widget.bankAccountName != null)
                          _infoRow('Atas Nama', widget.bankAccountName!),
                        if (widget.senderName != null)
                          _infoRow('Nama Pengirim', widget.senderName!),
                        _infoRow('Total Transfer', _formatPrice(order.totalAmount)),
                        _infoRow('Status', _paymentStatusLabel(order.paymentStatus)),
                        _infoRow('Tanggal', _formatDate(order.createdAt)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _infoCard(
                      icon: Icons.receipt_long_outlined,
                      children: [
                        const Text(
                          'Produk Dibeli',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: item.imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              item.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                Icons.inventory_2,
                                                color: Colors.grey,
                                                size: 20,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.inventory_2,
                                            color: Colors.grey,
                                            size: 20,
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.productName),
                                        if (item.color.isNotEmpty ||
                                            item.size.isNotEmpty)
                                          Text(
                                            [
                                              if (item.color.isNotEmpty)
                                                item.color,
                                              if (item.size.isNotEmpty)
                                                item.size,
                                            ].join(' / '),
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.quantity} x ${_formatPrice(item.price)}',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatPrice(item.subtotal),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formatPrice(order.totalAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xff2563EB),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _timelineCard(order),
                    if (order.paymentStatus == 'paid') ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade700),
                            const SizedBox(width: 12),
                            Text(
                              'Pembayaran Berhasil',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (order.paymentStatus == 'rejected') ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red.shade700),
                                const SizedBox(width: 12),
                                Text(
                                  'Bukti Transfer Ditolak',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _uploading ? null : () => _uploadReceipt(order),
                                icon: _uploading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.upload_file),
                                label: Text(
                                  _uploading ? 'Mengupload...' : 'Upload Bukti Transfer Ulang',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (order.paymentStatus == 'unpaid') ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _uploading ? null : () => _uploadReceipt(order),
                          icon: _uploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.upload_file),
                          label: Text(
                            _uploading ? 'Mengupload...' : 'Upload Bukti Transfer',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (order.receiptPdfFileId.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => _viewReceiptPdf(order.receiptPdfFileId),
                                icon: const Icon(Icons.description, size: 18),
                                label: const Text('Lihat Struk'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => _downloadReceiptPdf(order.receiptPdfFileId),
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text('Download Struk'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff2563EB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.popUntil(
                            context,
                            (route) => route.isFirst,
                          );
                        },
                        child: const Text(
                          'Kembali ke Toko',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const CustomerPage(initialIndex: 2),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          'Lihat Pesanan Saya',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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

  Future<void> _uploadReceipt(OrderModel order) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (picked == null || !mounted) return;

    setState(() => _uploading = true);

    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final allowed = ['jpg', 'jpeg', 'png', 'webp'];
      if (!allowed.contains(ext)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format file harus JPG, PNG, atau WEBP'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _uploading = false);
        return;
      }

      final storage = StorageServiceAppwrite();
      final fileId = await storage.uploadImage(
        bytes: bytes,
        fileName: 'payment_${order.orderCode}_${DateTime.now().millisecondsSinceEpoch}.$ext',
      );

      await OrderServiceAppwrite().updatePaymentReceipt(
        orderId: widget.orderId,
        receiptFileId: fileId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti transfer berhasil diupload'),
          backgroundColor: Colors.green,
        ),
      );

      _orderFuture = _loadOrder();
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal upload: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
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

  void _downloadReceiptPdf(String fileId) async {
    try {
      final bytes = await AppwriteService.storage.getFileDownload(
        bucketId: AppwriteConfig.productBucketId,
        fileId: fileId,
      );
      if (!mounted) return;
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'struk_pembayaran_$fileId.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendownload struk: $e')),
      );
    }
  }

  Widget _infoCard({
    required IconData icon,
    required List<Widget> children,
  }) {
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
              Icon(icon, size: 20, color: const Color(0xff2563EB)),
              const SizedBox(width: 8),
              const Text(
                'Informasi Pengiriman',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
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

  Widget _timelineCard(OrderModel order) {
    final status = order.status.toLowerCase();
    final isCancelled = status == 'cancelled';

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
              Icon(
                isCancelled ? Icons.cancel : Icons.timeline,
                size: 20,
                color: isCancelled ? Colors.red : const Color(0xff2563EB),
              ),
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
