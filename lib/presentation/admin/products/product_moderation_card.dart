import 'package:flutter/material.dart';

import '../../../core/utils/format_rupiah.dart';
import '../../../data/models/product_model.dart';

class ProductModerationCard extends StatelessWidget {
  final ProductModel product;
  final String adminName;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onDeactivate;
  final VoidCallback? onReactivate;

  const ProductModerationCard({
    super.key,
    required this.product,
    required this.adminName,
    this.onApprove,
    this.onReject,
    this.onDeactivate,
    this.onReactivate,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      case 'deactivated':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'pending':
        return 'Menunggu';
      case 'deactivated':
        return 'Dinonaktifkan';
      default:
        return status;
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';
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
    final status = product.moderationStatus;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(Icons.image, size: 48, color: Colors.grey),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatRupiah(product.price),
                    style: const TextStyle(
                      color: Color(0xff2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Stok: ${product.stock}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  Text(
                    'Seller: ${product.sellerId.length > 12 ? '${product.sellerId.substring(0, 12)}...' : product.sellerId}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                  if (product.moderationNote.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 12, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.moderationNote,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange.shade900,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (product.moderatedBy.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Oleh: ${product.moderatedBy}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                  if (product.moderatedAt != null) ...[
                    Text(
                      _formatDate(product.moderatedAt.toString()),
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                  const Spacer(),
                  _actionButtons(context, status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButtons(BuildContext context, String status) {
    switch (status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: onApprove,
                  child: const Text('Setujui', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: SizedBox(
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: onReject,
                  child: const Text('Tolak', style: TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
            ),
          ],
        );
      case 'approved':
        return SizedBox(
          width: double.infinity,
          height: 32,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.zero,
            ),
            onPressed: onDeactivate,
            child: const Text('Nonaktifkan', style: TextStyle(fontSize: 11, color: Colors.white)),
          ),
        );
      case 'rejected':
      case 'deactivated':
        return SizedBox(
          width: double.infinity,
          height: 32,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2563EB),
              padding: EdgeInsets.zero,
            ),
            onPressed: onReactivate,
            child: const Text('Aktifkan Kembali', style: TextStyle(fontSize: 11, color: Colors.white)),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
