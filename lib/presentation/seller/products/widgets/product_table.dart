//lib/presentation/seller/products/widgets/product_table.dart

import 'package:flutter/material.dart';
import '../../../../data/models/product_model.dart';
import '../../../../core/services/product_service_appwrite.dart';
import '../product_form_page.dart';
import '../../../../core/services/storage_service_appwrite.dart';
import '../form_produk_seller_web.dart';

class ProductTable extends StatelessWidget {
  final List<ProductModel> products;

  const ProductTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowHeight: 60,
      dataRowMinHeight: 70,
      dataRowMaxHeight: 70,
      columnSpacing: 40,
      horizontalMargin: 20,
      headingRowColor: WidgetStateProperty.all(const Color(0xffF8F9FC)),

      columns: const [
        DataColumn(
          label: Text("Produk", style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        DataColumn(
          label: Text(
            "Kategori",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        DataColumn(
          label: Text("Harga", style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        DataColumn(
          label: Text("Stok", style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        DataColumn(
          label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        DataColumn(
          label: Text("Aksi", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],

      rows: products.map((product) {
        return DataRow(
          cells: [
            // PRODUK
            DataCell(
              SizedBox(
                width: 450,
                child: Row(
                  children: [
                    _buildImage(product.imageUrl),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // KATEGORI
            DataCell(Text(product.category)),

            // HARGA
            DataCell(
              Text(
                "Rp ${_formatPrice(product.price)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            // STOK
            DataCell(
              Text(
                product.stock.toString(),
                style: TextStyle(
                  color: product.stock <= 5 ? Colors.red : Colors.black,
                  fontWeight: product.stock <= 5
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),

            // STATUS
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: product.active
                      ? Colors.green.shade50
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.active ? "Aktif" : "Nonaktif",
                  style: TextStyle(
                    color: product.active ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // AKSI
            DataCell(
              Row(
                children: [
                  // EDIT
                  IconButton(
                    tooltip: "Edit Produk",
                    onPressed: () {
                      onPressed:
                      () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductFormPage(product: product),
                          ),
                        );

                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FormProdukSellerWeb(),
                            ),
                          );
                        }
                      };
                    },
                    icon: const Icon(Icons.edit_outlined),
                  ),

                  // DELETE
                  IconButton(
                    tooltip: "Hapus Produk",
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Hapus Produk'),
                            content: Text(
                              'Yakin ingin menghapus ${product.name} ?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },
                                child: const Text('Hapus'),
                              ),
                            ],
                          );
                        },
                      );

                      if (result != true) return;

                      try {
                        final storageService = StorageServiceAppwrite();

                        final fileId = storageService.extractFileId(
                          product.imageUrl,
                        );

                        await storageService.deleteImage(fileId);

                        await ProductServiceAppwrite().deleteProduct(
                          product.id,
                        );

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produk berhasil dihapus'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menghapus produk: $e'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),

                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'detail',
                        child: Text('Lihat Detail'),
                      ),
                      const PopupMenuItem(
                        value: 'nonaktif',
                        child: Text('Nonaktifkan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.inventory_2),
      );
    }

    if (imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          width: 55,
          height: 55,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        imageUrl,
        width: 55,
        height: 55,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: 55,
          height: 55,
          color: Colors.grey.shade200,
          child: const Icon(Icons.image_not_supported),
        ),
      ),
    );
  }

  String _formatPrice(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}
