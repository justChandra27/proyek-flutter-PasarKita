//lib/presentation/seller/products/widgets/product_card.dart

import 'package:flutter/material.dart';

import '../../../../core/services/product_service_appwrite.dart';
import '../../../../core/services/storage_service_appwrite.dart';
import '../../../../data/models/product_model.dart';
import '../product_form_page.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onProductChanged;

  const ProductCard({
    super.key,
    required this.product,
    this.onProductChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),

        leading: _buildImage(),

        title: Text(
          product.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            "Stok : ${product.stock}",
          ),
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rp ${product.price.toStringAsFixed(0)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 18),
              onPressed: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductFormPage(product: product),
                  ),
                );
                if (result == true) onProductChanged?.call();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      if (product.imageUrl.isNotEmpty) {
        final storageService = StorageServiceAppwrite();
        final fileId = storageService.extractFileId(product.imageUrl);
        await storageService.deleteImage(fileId);
      }

      await ProductServiceAppwrite().deleteProduct(product.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil dihapus')),
        );
        onProductChanged?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus produk: $e')),
        );
      }
    }
  }

  Widget _buildImage() {
    // Tidak ada gambar
    if (product.imageUrl.isEmpty) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.inventory_2,
        ),
      );
    }

    // Gambar dari Appwrite Storage
    if (product.imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          product.imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) {
            return Container(
              width: 60,
              height: 60,
              color: Colors.grey.shade200,
              child: const Icon(
                Icons.broken_image,
              ),
            );
          },
        ),
      );
    }

    // Gambar dari Asset Flutter
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        product.imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.image_not_supported,
            ),
          );
        },
      ),
    );
  }
}