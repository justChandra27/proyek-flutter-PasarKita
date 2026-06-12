import 'package:flutter/material.dart';

import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';

class ProductDetailInfo extends StatelessWidget {
  final ProductModel product;
  final ProductReviewStats? reviewStats;

  const ProductDetailInfo({
    super.key,
    required this.product,
    this.reviewStats,
  });

  String _formatPrice(double price) {
    final p = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stock <= 0;
    final avg = reviewStats?.averageRating ?? 0;
    final count = reviewStats?.reviewCount ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _formatPrice(product.price),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xff2563EB),
          ),
        ),
        const SizedBox(height: 8),
        if (count > 0)
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                avg.toStringAsFixed(1),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($count ulasan)',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: outOfStock ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                outOfStock ? 'Stok Habis' : 'Tersedia ($product.stock)',
                style: TextStyle(
                  color: outOfStock ? Colors.red : Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Terjual ${product.soldCount}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _infoRow(Icons.monitor_weight_outlined, 'Berat', '${product.weight} gram'),
        const SizedBox(height: 8),
        _infoRow(Icons.shopping_cart_outlined, 'Min. Pembelian',
            '${product.minPurchase} pcs'),
        const SizedBox(height: 20),
        const Text(
          'Deskripsi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          product.description.isNotEmpty ? product.description : 'Tidak ada deskripsi',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
