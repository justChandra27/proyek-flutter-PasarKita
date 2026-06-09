//lib/presentation/seller/products/widgets/product_card.dart

import 'package:flutter/material.dart';

import '../../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
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

        trailing: Text(
          "Rp ${product.price.toStringAsFixed(0)}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
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