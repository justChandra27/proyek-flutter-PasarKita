import 'package:flutter/material.dart';
import 'package:pasarkita/presentation/product/product_detail_page.dart';

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

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (context) => ProductDetailPage(
              name: name,
              image: image,
              price: price,
            ),
          ),
        );
      },

      child: Container(

        decoration: BoxDecoration(

          color: const Color(0xFF1A1A1A),

          borderRadius: BorderRadius.circular(20),
        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Expanded(

              child: ClipRRect(

                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),

                child: Image.network(
                  image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(

              padding: const EdgeInsets.all(12),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    name,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(

                    price,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(

                        backgroundColor: const Color(0xFFD4AF37),

                        foregroundColor: Colors.black,
                      ),

                      onPressed: () {},

                      child: const Text("Add To Cart"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}