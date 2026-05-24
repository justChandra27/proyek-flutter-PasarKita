import 'package:flutter/material.dart';

import '../data/models/product_model.dart';
import '../../core/services/product_service.dart';
import '../presentation/product/add_product_page.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage> {

  final ProductService _productService =
      ProductService();

  late Future<List<ProductModel>>
      products;

  @override
  void initState() {

    super.initState();

    products =
        _productService.getProducts();
  }

  void refreshProducts() {

    setState(() {

      products =
          _productService.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'PasarKita',
        ),

        centerTitle: true,
      ),

      body:
          FutureBuilder<List<ProductModel>>(

        future: products,

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {

            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {

            return const Center(
              child: Text(
                'Produk kosong',
              ),
            );
          }

          final productList =
              snapshot.data!;

          return GridView.builder(

            padding:
                const EdgeInsets.all(20),

            itemCount:
                productList.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(

              crossAxisCount: 2,

              crossAxisSpacing: 16,

              mainAxisSpacing: 16,

              childAspectRatio: 0.75,
            ),

            itemBuilder:
                (context, index) {

              final product =
                  productList[index];

              return Container(

                decoration:
                    BoxDecoration(

                  color:
                      const Color(
                    0xFF1A1A1A,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    // IMAGE
                    Expanded(

                      flex: 6,

                      child: ClipRRect(

                        borderRadius:
                            const BorderRadius.vertical(

                          top: Radius.circular(
                            20,
                          ),
                        ),

                        child: SizedBox(

                          width:
                              double.infinity,

                          child: Image.asset(

                            product.imageUrl,

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
                            const EdgeInsets.all(
                          12,
                        ),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(

                              product.name,

                              maxLines: 1,

                              overflow:
                                  TextOverflow
                                      .ellipsis,

                              style:
                                  const TextStyle(

                                fontSize: 16,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(

                              'Rp ${product.price}',

                              style:
                                  const TextStyle(

                                color:
                                    Color(
                                  0xFFD4AF37,
                                ),

                                fontSize: 16,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const Spacer(),

                            Row(

                              children: [

                                Expanded(

                                  child:
                                      ElevatedButton(

                                    style:
                                        ElevatedButton.styleFrom(

                                      backgroundColor:
                                          const Color(
                                        0xFFD4AF37,
                                      ),

                                      foregroundColor:
                                          Colors
                                              .black,

                                      shape:
                                          RoundedRectangleBorder(

                                        borderRadius:
                                            BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                    ),

                                    onPressed:
                                        () {

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(

                                        const SnackBar(

                                          content:
                                              Text(
                                            'Fitur edit coming soon',
                                          ),
                                        ),
                                      );
                                    },

                                    child:
                                        const Icon(
                                      Icons.edit,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                Expanded(

                                  child:
                                      ElevatedButton(

                                    style:
                                        ElevatedButton.styleFrom(

                                      backgroundColor:
                                          Colors.red,

                                      foregroundColor:
                                          Colors
                                              .white,

                                      shape:
                                          RoundedRectangleBorder(

                                        borderRadius:
                                            BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                    ),

                                    onPressed:
                                        () async {

                                      await _productService
                                          .deleteProduct(
                                        product.id,
                                      );

                                      refreshProducts();
                                    },

                                    child:
                                        const Icon(
                                      Icons.delete,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            const Color(0xFFD4AF37),

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(
              builder: (_) =>
                  const AddProductPage(),
            ),
          ).then((_) {

            refreshProducts();
          });
        },

        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}