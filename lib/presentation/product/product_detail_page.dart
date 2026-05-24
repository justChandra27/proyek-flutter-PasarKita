import 'package:flutter/material.dart';

import '../../core/services/cart_service.dart';
import '../../data/models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final CartService _cartService = CartService();

  String selectedSize = '';
  String selectedColor = '';

  int quantity = 1;

  @override
  void initState() {
    super.initState();

    if (widget.product.sizes.isNotEmpty) {
      selectedSize = widget.product.sizes.first;
    }

    if (widget.product.colors.isNotEmpty) {
      selectedColor = widget.product.colors.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.name)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(20),

              child: Image.asset(
                widget.product.imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // NAME
            Text(
              widget.product.name,

              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // PRICE
            Text(
              'Rp ${widget.product.price}',

              style: const TextStyle(
                fontSize: 22,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // SIZE
            const Text(
              'Pilih Ukuran',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,

              children: widget.product.sizes.map((size) {
                return ChoiceChip(
                  label: Text(size),

                  selected: selectedSize == size,

                  onSelected: (_) {
                    setState(() {
                      selectedSize = size;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // COLOR
            const Text(
              'Pilih Warna',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,

              children: widget.product.colors.map((color) {
                return ChoiceChip(
                  label: Text(color),

                  selected: selectedColor == color,

                  onSelected: (_) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // QUANTITY
            const Text(
              'Jumlah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (quantity > 1) {
                      setState(() {
                        quantity--;
                      });
                    }
                  },

                  icon: const Icon(Icons.remove_circle),
                ),

                Text(quantity.toString(), style: const TextStyle(fontSize: 20)),

                IconButton(
                  onPressed: () {
                    setState(() {
                      quantity++;
                    });
                  },

                  icon: const Icon(Icons.add_circle),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () async {
                  await _cartService.addToCart(
                    product: widget.product,

                    size: selectedSize,

                    color: selectedColor,

                    quantity: quantity,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Produk masuk ke keranjang')),
                  );
                },

                child: const Text('Tambah ke Keranjang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
