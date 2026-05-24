// import 'package:flutter/material.dart';

// import '../data/models/product_model.dart';
// import '../../core/services/product_service.dart';

// class EditProductPage extends StatefulWidget {

//   final ProductModel product;

//   const EditProductPage({
//     super.key,
//     required this.product,
//   });

//   @override
//   State<EditProductPage> createState() =>
//       _EditProductPageState();
// }

// class _EditProductPageState
//     extends State<EditProductPage> {

//   final ProductService _productService =
//       ProductService();

//   late TextEditingController nameController;
//   late TextEditingController priceController;
//   late TextEditingController descriptionController;
//   late TextEditingController stockController;
//   late TextEditingController categoryController;

//   @override
//   void initState() {
//     super.initState();

//     nameController =
//         TextEditingController(text: widget.product.name);

//     priceController =
//         TextEditingController(
//           text: widget.product.price.toString(),
//         );

//     descriptionController =
//         TextEditingController(
//           text: widget.product.description,
//         );

//     stockController =
//         TextEditingController(
//           text: widget.product.stock.toString(),
//         );

//     categoryController =
//         TextEditingController(
//           text: widget.product.category,
//         );
//   }

//   Future<void> updateProduct() async {

//     await _productService.updateProduct(
//       id: widget.product.id,
//       name: nameController.text,
//       price: int.parse(priceController.text),
//       description: descriptionController.text,
//       stock: int.parse(stockController.text),
//       category: categoryController.text,
//     );

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Produk berhasil diupdate'),
//       ),
//     );

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Produk'),
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
//                 onPressed: updateProduct,

//                 child: const Text(
//                   'Update Produk',
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }