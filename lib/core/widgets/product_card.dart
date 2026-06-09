// import 'package:flutter/material.dart';

// import '../../data/models/product_model.dart';
// import '../../presentation/product/product_detail_page.dart';

// class ProductCard extends StatelessWidget {
//   final ProductModel product;

//   const ProductCard({
//     super.key,
//     required this.product,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ProductDetailPage(
//               product: product,
//             ),
//           ),
//         );
//       },

//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF171717),

//           borderRadius: BorderRadius.circular(18),

//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: 0.15),

//               blurRadius: 8,

//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),

//         child: Column(
//           crossAxisAlignment:
//               CrossAxisAlignment.start,

//           children: [
//             // IMAGE
//             Expanded(
//               flex: 6,

//               child: ClipRRect(
//                 borderRadius:
//                     const BorderRadius.vertical(
//                   top: Radius.circular(18),
//                 ),

//                 child: SizedBox(
//                   width: double.infinity,

//                   child: Image.asset(
//                     product.imageUrl,

//                     fit: BoxFit.cover,

//                     errorBuilder: (
//                       context,
//                       error,
//                       stackTrace,
//                     ) {
//                       return Container(
//                         color: Colors.grey.shade800,

//                         child: const Center(
//                           child: Icon(
//                             Icons.image_not_supported,
//                             color: Colors.white,
//                             size: 40,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),

//             // CONTENT
//             Expanded(
//               flex: 4,

//               child: Padding(
//                 padding:
//                     const EdgeInsets.all(12),

//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,

//                   children: [
//                     Text(
//                       product.name,

//                       maxLines: 1,

//                       overflow:
//                           TextOverflow.ellipsis,

//                       style:
//                           const TextStyle(
//                         color: Colors.white,

//                         fontSize: 16,

//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 6),

//                     Text(
//                       'Rp ${product.price}',

//                       style:
//                           const TextStyle(
//                         color:
//                             Color(0xFFD4AF37),

//                         fontSize: 17,

//                         fontWeight:
//                             FontWeight.bold,
//                       ),
//                     ),

//                     const SizedBox(height: 6),

//                     Text(
//                       'Stok: ${product.stock}',

//                       style:
//                           const TextStyle(
//                         color: Colors.grey,

//                         fontSize: 12,
//                       ),
//                     ),

//                     const Spacer(),

//                     SizedBox(
//                       width: double.infinity,

//                       height: 38,

//                       child: ElevatedButton(
//                         style:
//                             ElevatedButton.styleFrom(
//                           backgroundColor:
//                               const Color(
//                             0xFFD4AF37,
//                           ),

//                           foregroundColor:
//                               Colors.black,

//                           elevation: 0,

//                           padding:
//                               EdgeInsets.zero,

//                           shape:
//                               RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.circular(
//                               10,
//                             ),
//                           ),
//                         ),

//                         onPressed: () {
//                           Navigator.push(
//                             context,

//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   ProductDetailPage(
//                                 product:
//                                     product,
//                               ),
//                             ),
//                           );
//                         },

//                         child: const Text(
//                           'Lihat Detail',

//                           style: TextStyle(
//                             fontWeight:
//                                 FontWeight.bold,

//                             fontSize: 13,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }