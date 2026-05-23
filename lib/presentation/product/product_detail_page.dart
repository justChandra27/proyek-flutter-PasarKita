import 'package:flutter/material.dart';

import 'widgets/size_selector.dart';
import 'widgets/color_selector.dart';
import 'widgets/add_to_cart_button.dart';

class ProductDetailPage extends StatelessWidget {

  final String name;
  final String image;
  final String price;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.image,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text(name),
      ),

      body: SingleChildScrollView(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // PRODUCT IMAGE
            SizedBox(

              height: 350,
              width: double.infinity,

              child: Image.network(
                image,
                fit: BoxFit.cover,
              ),
            ),

            Padding(

              padding: const EdgeInsets.all(20),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  // PRODUCT NAME
                  Text(

                    name,

                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // PRICE
                  Text(

                    price,

                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SIZE TITLE
                  const Text(

                    "Ukuran",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // SIZE SELECTOR
                  const Row(

                    children: [

                      SizeSelector(size: "S"),
                      SizeSelector(size: "M"),
                      SizeSelector(size: "L"),
                      SizeSelector(size: "XL"),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // COLOR TITLE
                  const Text(

                    "Warna",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // COLOR SELECTOR
                  const Row(

                    children: [

                      ColorSelector(color: Colors.black),
                      ColorSelector(color: Colors.red),
                      ColorSelector(color: Colors.blue),
                      ColorSelector(color: Colors.green),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // DESCRIPTION TITLE
                  const Text(

                    "Deskripsi",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(

                    "Premium fashion dengan kualitas terbaik dan nyaman digunakan sehari-hari.",

                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ADD TO CART BUTTON
                  const AddToCartButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}