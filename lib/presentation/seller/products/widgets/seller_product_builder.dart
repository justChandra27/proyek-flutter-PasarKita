//lib/presentation/seller/products/widgets/seller_product_builder.dart

import 'package:flutter/material.dart';

import '../../../../core/appwrite/appwrite_service.dart';
import '../../../../core/services/product_service_appwrite.dart';
import '../../../../data/models/product_model.dart';

class SellerProductBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    List<ProductModel> products,
  ) builder;

  const SellerProductBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppwriteService.account.get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!userSnapshot.hasData) {
          return const Center(
            child: Text(
              'User belum login',
            ),
          );
        }

        final sellerId =
            userSnapshot.data!.$id;

        return FutureBuilder<List<ProductModel>>(
          future: ProductServiceAppwrite()
              .getSellerProducts(
            sellerId,
          ),
          builder: (
            context,
            productSnapshot,
          ) {
            if (productSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            if (!productSnapshot.hasData ||
                productSnapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada produk',
                ),
              );
            }

            return builder(
              context,
              productSnapshot.data!,
            );
          },
        );
      },
    );
  }
}