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
  final int weight;
  final int minPurchase;
  final int soldCount;
  final List<String> colors;
  final List<String> sizes;
  final String moderationNote;
  final String moderationStatus;
  final String moderatedBy;
  final DateTime? moderatedAt;

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
    required this.weight,
    required this.minPurchase,
    required this.soldCount,
    this.colors = const [],
    this.sizes = const [],
    this.moderationNote = '',
    this.moderationStatus = 'approved',
    this.moderatedBy = '',
    this.moderatedAt,
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
      weight: (data['weight'] as num?)?.toInt() ?? 0,
      minPurchase: data['minPurchase'] ?? 1,
      soldCount: data['soldCount'] ?? 0,
      colors: (data['colors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      sizes: (data['sizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      moderationNote: data['moderationNote'] ?? '',
      moderationStatus: data['moderationStatus'] ?? 'approved',
      moderatedBy: data['moderatedBy'] ?? '',
      moderatedAt: data['moderatedAt'] != null
          ? DateTime.tryParse(data['moderatedAt'])
          : null,
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
      'weight': weight,
      'minPurchase': minPurchase,
      'soldCount': soldCount,
      'colors': colors,
      'sizes': sizes,
      'moderationNote': moderationNote,
      'moderationStatus': moderationStatus,
      'moderatedBy': moderatedBy,
      'moderatedAt': moderatedAt?.toIso8601String(),
    };
  }
}