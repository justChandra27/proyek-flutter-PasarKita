//lib/presentation/seller/products/widgets/product_table_modern.dart

import 'package:flutter/material.dart';

import '../../../../data/models/product_model.dart';
import '../product_form_page.dart';

class ProductTableModern extends StatelessWidget {
  final List<ProductModel> products;

  const ProductTableModern({
    super.key,
    required this.products,
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
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: product.active
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              child: Text(
                product.active
                    ? "Aktif"
                    : "Nonaktif",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: product.active
                      ? Colors.green
                      : Colors.grey,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),

          SizedBox(
            width: 120,
            child: Row(
              children: [
                IconButton(
                  tooltip: "Edit",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductFormPage(
                          product: product,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                  ),
                ),

                IconButton(
                  tooltip: "Hapus",
                  onPressed: () {},
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                ),

                PopupMenuButton(
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