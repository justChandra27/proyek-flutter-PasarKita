class ProductModel {

  final String id;
  final String name;
  final int price;
  final String description;
  final String imageUrl;
  final int stock;
  final String category;

  final List<dynamic> sizes;
  final List<dynamic> colors;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.stock,
    required this.category,
    required this.sizes,
    required this.colors,
  });

  factory ProductModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {

    return ProductModel(
      id: documentId,

      name: data['name'] ?? '',

      price: data['price'] ?? 0,

      description:
          data['description'] ?? '',

      imageUrl:
          data['imageUrl'] ?? '',

      stock: data['stock'] ?? 0,

      category:
          data['category'] ?? '',

      sizes: data['sizes'] ?? [],

      colors: data['colors'] ?? [],
    );
  }

  Map<String, dynamic> toMap() {

    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'stock': stock,
      'category': category,
      'sizes': sizes,
      'colors': colors,
    };
  }
}