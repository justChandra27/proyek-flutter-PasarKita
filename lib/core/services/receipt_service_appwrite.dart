import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr/qr.dart';

import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';

class ReceiptServiceAppwrite {
  final Databases _db = AppwriteService.databases;

  Future<String> generateReceiptNumber(String orderId) async {
    final now = DateTime.now();
    final date = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final suffix = orderId.length >= 4
        ? orderId.substring(orderId.length - 4).toUpperCase()
        : orderId.padLeft(4, '0').toUpperCase();
    return 'PKT-$date-$suffix';
  }

  Future<Map<String, dynamic>> _getUserData(String uid) async {
    final result = await _db.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.usersCollectionId,
      queries: [Query.equal('uid', uid), Query.limit(1)],
    );
    if (result.documents.isEmpty) return {};
    return result.documents.first.data;
  }

  Uint8List _generateQrCodeImage(String data) {
    try {
      final qrCode = QrCode(10, QrErrorCorrectLevel.H)..addData(data);
      final qrImg = QrImage(qrCode);
      final modules = qrCode.moduleCount;
      const scale = 8;
      const padding = 4;
      final size = (modules + 2 * padding) * scale;

      final image = img.Image(width: size, height: size);

      for (int y = 0; y < size; y++) {
        for (int x = 0; x < size; x++) {
          image.setPixelRgba(x, y, 255, 255, 255, 255);
        }
      }

      for (int y = 0; y < modules; y++) {
        for (int x = 0; x < modules; x++) {
          if (qrImg.isDark(y, x)) {
            final px = (x + padding) * scale;
            final py = (y + padding) * scale;
            for (int dy = 0; dy < scale; dy++) {
              for (int dx = 0; dx < scale; dx++) {
                image.setPixelRgba(px + dx, py + dy, 0, 0, 0, 255);
              }
            }
          }
        }
      }

      return img.encodePng(image);
    } catch (_) {
      return Uint8List(0);
    }
  }

  Future<Uint8List> generateReceiptPdf({
    required OrderModel order,
    required List<OrderItemModel> items,
    required String receiptNumber,
    required String customerName,
    required String customerEmail,
    required List<Map<String, String>> sellers,
  }) async {
    final pdf = pw.Document();

    final itemsSubtotal = items.fold<int>(0, (s, i) => s + i.subtotal);
    final totalPlatformFee = items.fold<int>(0, (s, i) => s + i.platformFee);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Header(
            level: 0,
            text: 'PASARKITA',
            textStyle: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.Header(
            level: 1,
            text: 'BUKTI PEMBAYARAN PESANAN',
            textStyle: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 10),

          pw.Header(
            level: 2,
            text: 'Informasi Transaksi',
            textStyle: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          _infoRow('Total Transaksi', 'Rp ${_formatAmount(order.totalAmount)}'),
          _infoRow('Nomor Referensi', receiptNumber),
          _infoRow('ID Pesanan', order.orderCode),
          _infoRow('Tanggal Pembayaran', _formatDate(order.createdAt)),
          _infoRow('Metode Pembayaran', order.paymentMethod),
          _infoRow('Status Pembayaran', 'Lunas'),
          pw.SizedBox(height: 16),

          pw.Header(
            level: 2,
            text: 'Tujuan Pembayaran',
            textStyle: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (sellers.isNotEmpty) ...[
            _infoRow('Nama Toko', sellers.first['storeName'] ?? '-'),
            _infoRow('Nama Seller', sellers.first['name'] ?? '-'),
            _infoRow('Kota Seller', sellers.first['city'] ?? '-'),
          ],
          pw.SizedBox(height: 16),

          pw.Header(
            level: 2,
            text: 'Data Customer',
            textStyle: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          _infoRow('Nama Customer', customerName),
          _infoRow('Email Customer', customerEmail),
          pw.SizedBox(height: 16),

          pw.Header(
            level: 2,
            text: 'Data Seller',
            textStyle: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (sellers.isNotEmpty) ...[
            _infoRow('Nama Seller', sellers.first['name'] ?? '-'),
            _infoRow('Nama Toko', sellers.first['storeName'] ?? '-'),
            _infoRow('Email Seller', sellers.first['email'] ?? '-'),
          ],
          pw.SizedBox(height: 16),

          pw.Header(
            level: 2,
            text: 'Detail Produk',
            textStyle: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  _tableCell('Nama Produk', isHeader: true),
                  _tableCell('Qty', isHeader: true),
                  _tableCell('Harga', isHeader: true),
                  _tableCell('Subtotal', isHeader: true),
                ],
              ),
              ...items.map((item) => pw.TableRow(
                children: [
                  _tableCell(item.productName),
                  _tableCell('${item.quantity}'),
                  _tableCell('Rp ${_formatAmount(item.price)}'),
                  _tableCell('Rp ${_formatAmount(item.subtotal)}'),
                ],
              )),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Header(
            level: 2,
            text: 'Ringkasan',
            textStyle: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          _infoRow('Subtotal', 'Rp ${_formatAmount(itemsSubtotal)}'),
          _infoRow('Biaya Platform', 'Rp ${_formatAmount(totalPlatformFee)}'),
          pw.Divider(thickness: 1),
          _infoRow(
            'Total Pembayaran',
            'Rp ${_formatAmount(order.totalAmount)}',
            isBold: true,
          ),
          pw.SizedBox(height: 24),

          pw.Divider(thickness: 1),
          pw.SizedBox(height: 16),
          pw.Center(
            child: pw.Text(
              'QR VERIFICATION',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.SizedBox(height: 12),
          _qrCodeSection(receiptNumber, order.id),
          pw.SizedBox(height: 12),
          pw.Center(
            child: pw.Text(
              'Scan untuk memverifikasi transaksi',
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey400,
              ),
            ),
          ),
          pw.SizedBox(height: 20),

          pw.Divider(thickness: 1),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'PASARKITA MARKETPLACE',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(
            child: pw.Text(
              'Bukti transaksi resmi PasarKita',
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColors.grey400,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _infoRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _qrCodeSection(String receiptNumber, String orderId) {
    final jsonData = '{"receiptNumber":"$receiptNumber","orderId":"$orderId","paymentStatus":"paid"}';
    final qrBytes = _generateQrCodeImage(jsonData);

    if (qrBytes.isEmpty) {
      return pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Center(
          child: pw.Text(
            'QR GENERATION FAILED',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey500,
            ),
          ),
        ),
      );
    }

    return pw.Center(
      child: pw.Image(
        pw.MemoryImage(qrBytes),
        width: 120,
        height: 120,
      ),
    );
  }

  pw.Widget _tableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  String _formatAmount(int amount) {
    final str = amount.toString();
    final parts = <String>[];
    int end = str.length;
    while (end > 0) {
      final start = (end - 3).clamp(0, end);
      parts.insert(0, str.substring(start, end));
      end = start;
    }
    return parts.join('.');
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

  Future<void> generateAndUploadReceipt({
    required OrderModel order,
    required List<OrderItemModel> items,
  }) async {
    try {
      final receiptNumber = await generateReceiptNumber(order.id);

      final sellerIds = items.map((i) => i.sellerId).toSet().toList();
      final sellers = <Map<String, String>>[];
      for (final sid in sellerIds) {
        final data = await _getUserData(sid);
        sellers.add({
          'name': (data['name'] as String?) ?? '',
          'storeName': (data['storeName'] as String?) ?? '',
          'email': (data['email'] as String?) ?? '',
          'city': (data['city'] as String?) ?? '',
        });
      }

      final pdfBytes = await generateReceiptPdf(
        order: order,
        items: items,
        receiptNumber: receiptNumber,
        customerName: order.customerName,
        customerEmail: order.customerEmail,
        sellers: sellers,
      );

      final storage = AppwriteService.storage;
      final uploadResult = await storage.createFile(
        bucketId: AppwriteConfig.productBucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: pdfBytes,
          filename: 'struk_$receiptNumber.pdf',
        ),
      );

      final now = DateTime.now().toIso8601String();
      await _db.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.ordersCollectionId,
        documentId: order.id,
        data: {
          'receiptNumber': receiptNumber,
          'receiptPdfFileId': uploadResult.$id,
          'receiptGeneratedAt': now,
        },
      );
    } catch (e) {
      // Jangan rollback paymentStatus — tetap paid
      // Cukup log error
    }
  }
}
