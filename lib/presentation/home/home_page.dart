import 'package:flutter/material.dart';

import '../../core/services/product_service.dart';
import '../../core/widgets/product_card.dart';
import '../../data/models/product_model.dart';

import 'widgets/banner_slider.dart';
import 'widgets/category_item.dart';
import 'widgets/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProductService _productService = ProductService();

  late Future<List<ProductModel>> products;

  @override
  void initState() {
    super.initState();

    products = _productService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PasarKita"),

        centerTitle: true,

        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),

        actions: [
          IconButton(
            onPressed: () {},

            icon: const Icon(Icons.notifications_none),
          ),
        ],
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

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 15),

          // CATEGORY LIST
          SizedBox(
            height: 50,

            child: ListView(
              scrollDirection: Axis.horizontal,

              padding: const EdgeInsets.symmetric(horizontal: 20),

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

              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          // PRODUCT GRID
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: FutureBuilder<List<ProductModel>>(
              future: products,

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Produk kosong'));
                }

                final productList = snapshot.data!;

                return GridView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: productList.length,

                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,

                    childAspectRatio: 0.82,
                  ),

                  itemBuilder: (context, index) {
                    final product = productList[index];

                    return ProductCard(
                      name: product.name,
                      image: product.imageUrl,
                      price: 'Rp ${product.price}',
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
