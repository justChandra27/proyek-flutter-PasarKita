//lib/presentation/seller/products/widgets/product_table_modern.dart

import 'package:flutter/material.dart';

import '../../../../data/models/product_model.dart';
import '../../../../data/models/moderation_status.dart';
import '../../../../core/services/product_service_appwrite.dart';
import '../../../../core/services/storage_service_appwrite.dart';
import '../detail_produk_seller_web.dart';
import '../product_form_page.dart';
import 'moderation_status_badge.dart';

class ProductTableModern extends StatelessWidget {
  final List<ProductModel> products;
  final VoidCallback? onProductChanged;

  const ProductTableModern({
    super.key,
    required this.products,
    this.onProductChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _buildHeader(),

          const Divider(height: 1),

          Expanded(
            child: ListView.separated(
              itemCount: products.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = products[index];

                return _buildRow(
                  context,
                  product,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: const Row(
        children: [
          SizedBox(width: 320, child: Text(
            "Info Produk",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )),

          Expanded(
            child: Text(
              "Kategori",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              "Harga",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              "Stok",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(
              "Status",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(
            width: 120,
            child: Text(
              "Aksi",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    ProductModel product,
  ) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 320,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, _, _) =>
                            Container(
                      width: 60,
                      height: 60,
                      color:
                          Colors.grey.shade200,
                      child: const Icon(
                        Icons.image,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "SKU: ${product.id.substring(0, 8)}",
                        style:
                            const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Text(
              product.category,
            ),
          ),

          Expanded(
            child: Text(
              "Rp ${_formatPrice(product.price)}",
              style: const TextStyle(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  "${product.stock} Unit",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.w600,
                    color: product.stock <= 5
                        ? Colors.red
                        : Colors.black,
                  ),
                ),

                if (product.stock <= 5)
                  const Text(
                    "STOK MENIPIS",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          Expanded(
            child: ModerationStatusBadge(
              status: ModerationStatus.fromJson(product.moderationStatus),
            ),
          ),

          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  tooltip: "Edit",
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductFormPage(
                          product: product,
                        ),
                      ),
                    );
                    if (result == true) {
                      onProductChanged?.call();
                    }
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                ),

                IconButton(
                  tooltip: "Hapus",
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Produk'),
                        content: Text('Yakin ingin menghapus ${product.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Hapus'),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true) return;
                    try {
                      final storageService = StorageServiceAppwrite();
                      final fileId = storageService.extractFileId(product.imageUrl);
                      await storageService.deleteImage(fileId);
                      await ProductServiceAppwrite().deleteProduct(product.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Produk berhasil dihapus')),
                        );
                      }
                      onProductChanged?.call();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Gagal menghapus: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),

                PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'detail') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailProdukSellerWeb(
                            productId: product.id,
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'detail',
                      child: Text(
                        'Detail',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(
    double value,
  ) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(
            r'(\d{1,3})(?=(\d{3})+(?!\d))',
          ),
          (Match m) => '${m[1]}.',
        );
  }
}