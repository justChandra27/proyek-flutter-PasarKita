import 'package:flutter/material.dart';

import '../../data/models/product_model.dart';
import '../../presentation/product/product_detail_page.dart';

class ProductCard extends StatelessWidget {

  final String name;
  final String image;
  final String price;

  const ProductCard({

    super.key,

    required this.name,

    required this.image,

    required this.price,
  });

  @override
  Widget build(BuildContext context) {

    final product =
        ProductModel(

      id: '',

      name: name,

      price: int.parse(
        price.replaceAll(
          'Rp ',
          '',
        ),
      ),

      description: '',

      imageUrl: image,

      stock: 0,

      category: '',

      sizes: ['M', 'L', 'XL'],

      colors: [
        'Black',
        'White',
      ],
    );

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(
            builder: (_) =>
                ProductDetailPage(
              product: product,
            ),
          ),
        );
      },

      child: Container(

        decoration: BoxDecoration(

          color: const Color(0xFF171717),

          borderRadius:
              BorderRadius.circular(18),

          boxShadow: [

            BoxShadow(

              color:
                  Colors.black.withOpacity(
                0.15,
              ),

              blurRadius: 8,

              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // IMAGE
            Expanded(

              flex: 6,

              child: ClipRRect(

                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),

                child: SizedBox(

                  width: double.infinity,

                  child: Image.asset(

                    image,

                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // CONTENT
            Expanded(

              flex: 4,

              child: Padding(

                padding:
                    const EdgeInsets.all(12),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(

                      name,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(

                        color: Colors.white,

                        fontSize: 16,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(

                      price,

                      style:
                          const TextStyle(

                        color:
                            Color(0xFFD4AF37),

                        fontSize: 17,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const Spacer(),

                    SizedBox(

                      width: double.infinity,

                      height: 38,

                      child: ElevatedButton(

                        style:
                            ElevatedButton.styleFrom(

                          backgroundColor:
                              const Color(
                            0xFFD4AF37,
                          ),

                          foregroundColor:
                              Colors.black,

                          elevation: 0,

                          padding:
                              EdgeInsets.zero,

                          shape:
                              RoundedRectangleBorder(

                            borderRadius:
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                        ),

                        onPressed: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(
                              builder: (_) =>
                                  ProductDetailPage(
                                product: product,
                              ),
                            ),
                          );
                        },

                        child: const Text(

                          'Tambah',

                          style: TextStyle(

                            fontWeight:
                                FontWeight.bold,

                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}