import 'package:flutter/material.dart';

import '../../../core/widgets/product_card.dart';

import 'banner_slider.dart';
import 'category_item.dart';
import 'search_bar.dart';

class HomePage extends StatelessWidget {

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("PasarKita"),
      ),

      body: ListView(

        children: [

          // BANNER
          const BannerSlider(),

          // SEARCH
          const SearchBarWidget(),

          const SizedBox(height: 20),

          // CATEGORY TITLE
          const Padding(

            padding: EdgeInsets.symmetric(horizontal: 16),

            child: Text(

              "Kategori",

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 15),

          // CATEGORY LIST
          SizedBox(

            height: 50,

            child: ListView(

              scrollDirection: Axis.horizontal,

              padding: const EdgeInsets.symmetric(horizontal: 16),

              children: const [

                CategoryItem(title: "Hoodie"),
                CategoryItem(title: "Jacket"),
                CategoryItem(title: "Shoes"),
                CategoryItem(title: "T-Shirt"),
                CategoryItem(title: "Celana"),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // PRODUCT TITLE
          const Padding(

            padding: EdgeInsets.symmetric(horizontal: 16),

            child: Text(

              "Produk Terbaru",

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // PRODUCT GRID
          Padding(

            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: GridView.count(

              crossAxisCount: 2,

              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              crossAxisSpacing: 16,

              mainAxisSpacing: 16,

              childAspectRatio: 0.62,

              children: const [

                ProductCard(
                  name: "Premium Hoodie",
                  image: "https://picsum.photos/300/300",
                  price: "Rp 250.000",
                ),

                ProductCard(
                  name: "Elegant Jacket",
                  image: "https://picsum.photos/301/300",
                  price: "Rp 350.000",
                ),

                ProductCard(
                  name: "Fashion T-Shirt",
                  image: "https://picsum.photos/302/300",
                  price: "Rp 150.000",
                ),

                ProductCard(
                  name: "Luxury Sneakers",
                  image: "https://picsum.photos/303/300",
                  price: "Rp 550.000",
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}