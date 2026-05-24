import 'package:flutter/material.dart';

import '../../core/services/product_service.dart';
import '../../data/models/product_model.dart';


class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final ProductService _productService = ProductService();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _imageController = TextEditingController();

  final TextEditingController _stockController = TextEditingController();

  final TextEditingController _categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // NAME
            TextField(
              controller: _nameController,

              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),

            const SizedBox(height: 16),

            // PRICE
            TextField(
              controller: _priceController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: 'Harga'),
            ),

            const SizedBox(height: 16),

            // DESCRIPTION
            TextField(
              controller: _descriptionController,

              decoration: const InputDecoration(labelText: 'Deskripsi'),
            ),

            const SizedBox(height: 16),

            // IMAGE
            TextField(
              controller: _imageController,

              decoration: const InputDecoration(
                labelText: 'Path Gambar',

                hintText: 'assets/images/pria/baju.jpg',
              ),
            ),

            const SizedBox(height: 16),

            // STOCK
            TextField(
              controller: _stockController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(labelText: 'Stock'),
            ),

            const SizedBox(height: 16),

            // CATEGORY
            TextField(
              controller: _categoryController,

              decoration: const InputDecoration(labelText: 'Kategori'),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              height: 50,

              child: ElevatedButton(
                onPressed: () async {
                  final product = ProductModel(
                    id: '',

                    name: _nameController.text,

                    price: int.parse(_priceController.text),

                    description: _descriptionController.text,

                    imageUrl: _imageController.text,

                    stock: int.parse(_stockController.text),

                    category: _categoryController.text,

                    sizes: ['M', 'L', 'XL'],

                    colors: ['Black', 'White'],
                  );

                  await _productService.addProduct(product);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Produk berhasil ditambahkan'),
                      ),
                    );

                    Navigator.pop(context);
                  }
                },

                child: const Text('Tambah Produk'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
