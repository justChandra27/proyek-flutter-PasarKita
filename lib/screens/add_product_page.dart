// import 'package:flutter/material.dart';

// import '../../core/services/product_service.dart';
// import '../../data/models/product_model.dart';

// class AddProductPage extends StatefulWidget {
//   const AddProductPage({super.key});

//   @override
//   State<AddProductPage> createState() =>
//       _AddProductPageState();
// }

// class _AddProductPageState
//     extends State<AddProductPage> {

//   final ProductService _productService =
//       ProductService();

//   final TextEditingController nameController =
//       TextEditingController();

//   final TextEditingController priceController =
//       TextEditingController();

//   final TextEditingController descriptionController =
//       TextEditingController();

//   final TextEditingController stockController =
//       TextEditingController();

//   final TextEditingController categoryController =
//       TextEditingController();

//   Future<void> saveProduct() async {

//     final product =
//     ProductModel(

//   id: '',

//   name:
//       _nameController.text,

//   price: int.parse(
//     _priceController.text,
//   ),

//   description:
//       _descriptionController.text,

//   imageUrl:
//       _imageController.text,

//   stock: int.parse(
//     _stockController.text,
//   ),

//   category:
//       _categoryController.text,

//   sizes: [
//     'M',
//     'L',
//     'XL',
//   ],

//   colors: [
//     'Black',
//     'White',
//   ],
// );

// await _productService
//     .addProduct(product);

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Produk berhasil ditambahkan'),
//       ),
//     );

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tambah Produk'),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),

//         child: Column(
//           children: [

//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Nama Produk',
//               ),
//             ),

//             const SizedBox(height: 16),

//             TextField(
//               controller: priceController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Harga',
//               ),
//             ),

//             const SizedBox(height: 16),

//             TextField(
//               controller: descriptionController,
//               decoration: const InputDecoration(
//                 labelText: 'Deskripsi',
//               ),
//             ),

//             const SizedBox(height: 16),

//             TextField(
//               controller: stockController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Stock',
//               ),
//             ),

//             const SizedBox(height: 16),

//             TextField(
//               controller: categoryController,
//               decoration: const InputDecoration(
//                 labelText: 'Kategori',
//               ),
//             ),

//             const SizedBox(height: 30),

//             SizedBox(
//               width: double.infinity,

//               child: ElevatedButton(
//                 onPressed: saveProduct,

//                 child: const Text(
//                   'Simpan Produk',
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }