//lib/core/services/product_service_appwrite.dart

import 'package:appwrite/appwrite.dart';

import '../../data/models/product_model.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';

class ProductServiceAppwrite {
  final Databases databases = AppwriteService.databases;

  // =========================
  // GET PRODUCT SELLER
  // =========================

  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      queries: [Query.equal('sellerId', sellerId)],
    );

    return result.documents.map((doc) {
      return ProductModel.fromMap(doc.$id, doc.data);
    }).toList();
  }

  // =========================
  // ADD PRODUCT
  // =========================

  Future<void> addProduct({
    required String sellerId,
    required String name,
    required String category,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
  }) async {
    await databases.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      documentId: ID.unique(),
      data: {
        'sellerId': sellerId,
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'active': true,
      },
    );
  }

  // =========================
  // UPDATE PRODUCT
  // =========================

  Future<void> updateProduct({
    required String productId,
    required String name,
    required String category,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required bool active,
  }) async {
    await databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      documentId: productId,
      data: {
        'name': name,
        'description': description,
        'category': category,
        'price': price,
        'stock': stock,
        'imageUrl': imageUrl,
        'active': active,
      },
    );
  }

  // =========================
  // DELETE PRODUCT
  // =========================

  Future<void> deleteProduct(String productId) async {
    await databases.deleteDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      documentId: productId,
    );
  }
}
