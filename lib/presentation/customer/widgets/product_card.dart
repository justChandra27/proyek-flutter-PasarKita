import 'package:flutter/material.dart';

import '../../../data/models/product_model.dart';
import '../../../data/models/review_model.dart';
import '../../../core/utils/format_rupiah.dart';
import 'star_rating_row.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final ProductReviewStats? reviewStats;
  final VoidCallback? onTap;
  final VoidCallback? onRatingTap;
  final VoidCallback onAddToCart;

  final double borderRadius;
  final bool addBorder;
  final EdgeInsets contentPadding;
  final double nameFontSize;
  final double? priceFontSize;
  final Color? stockInStockColor;
  final Widget errorImage;
  final EdgeInsets outOfStockPadding;
  final double outOfStockFontSize;
  final double outOfStockRadius;
  final CrossAxisAlignment crossAxisAlignment;
  final bool showStockText;
  final bool showSoldCount;
  final List<BoxShadow>? boxShadow;
  final Widget Function(bool outOfStock, VoidCallback onAddToCart) buttonBuilder;

  const ProductCard({
    super.key,
    required this.product,
    this.reviewStats,
    this.onTap,
    this.onRatingTap,
    required this.onAddToCart,
    this.borderRadius = 16,
    this.addBorder = false,
    this.contentPadding = const EdgeInsets.all(14),
    this.nameFontSize = 24,
    this.priceFontSize,
    this.stockInStockColor,
    this.errorImage = const Icon(Icons.image, size: 60, color: Colors.black54),
    this.outOfStockPadding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.outOfStockFontSize = 14,
    this.outOfStockRadius = 8,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.showStockText = true,
    this.showSoldCount = false,
    this.boxShadow,
    required this.buttonBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stock <= 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: addBorder ? Border.all(color: Colors.black12) : null,
          boxShadow: boxShadow,
        ),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(borderRadius),
                      ),
                    ),
                    child: product.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(borderRadius),
                            ),
                            child: Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, _, _) => errorImage,
                            ),
                          )
                        : errorImage,
                  ),
                  if (outOfStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: outOfStockPadding,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(outOfStockRadius),
                        ),
                        child: Text(
                          'Stok Habis',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: outOfStockFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatRupiah(product.price),
                    style: TextStyle(
                      color: const Color(0xff2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: priceFontSize,
                    ),
                  ),
                  if (showSoldCount && product.soldCount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.trending_up, size: 13, color: Colors.grey),
                        const SizedBox(width: 3),
                        Text(
                          'Terjual ${product.soldCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (showStockText) ...[
                    const SizedBox(height: 4),
                    Text(
                      outOfStock ? 'Stok: Habis' : 'Stok: ${product.stock}',
                      style: TextStyle(
                        color: outOfStock ? Colors.red : stockInStockColor,
                      ),
                    ),
                  ],
                  if (reviewStats != null && reviewStats!.reviewCount > 0) ...[
                    const SizedBox(height: 4),
                    StarRatingRow(
                      averageRating: reviewStats!.averageRating,
                      reviewCount: reviewStats!.reviewCount,
                      onTap: onRatingTap,
                    ),
                  ],
                  const SizedBox(height: 12),
                  buttonBuilder(outOfStock, onAddToCart),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
