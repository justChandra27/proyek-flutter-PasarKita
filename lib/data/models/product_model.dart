//lib/data/models/product_model.dart

class ProductModel {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stock;
  final String imageUrl;
  final bool active;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.active,
  });

  factory ProductModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProductModel(
      id: id,
      sellerId: data['sellerId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      active: data['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'active': active,
    };
  }
}