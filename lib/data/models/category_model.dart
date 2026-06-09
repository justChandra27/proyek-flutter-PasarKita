//lib/data/models/category_model.dart

class CategoryModel {
  final String documentId;
  final String name;
  final String description;
  final String imageUrl;
  final int productCount;
  final String status;

  CategoryModel({
    required this.documentId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.productCount,
    required this.status,
  });

  factory CategoryModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return CategoryModel(
      documentId: documentId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      productCount: map['productCount'] ?? 0,
      status: map['status'] ?? 'active',
    );
  }
}