//lib/core/services/product_service_appwrite.dart

import 'package:appwrite/appwrite.dart';

import '../../data/models/product_model.dart';
import '../../data/models/moderation_status.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import '../models/paginated_response.dart';

class ProductServiceAppwrite {
  final Databases databases = AppwriteService.databases;

  // =========================
  // GET ALL PRODUCTS (admin — no active filter)
  // =========================

  Future<List<ProductModel>> getAllProductsForAdmin() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      queries: [Query.limit(100)],
    );

    return result.documents.map((doc) {
      return ProductModel.fromMap(doc.$id, doc.data);
    }).toList();
  }

  // =========================
  // GET PRODUCTS BY MODERATION STATUS
  // =========================

  Future<List<ProductModel>> getProductsByStatus(ModerationStatus status) async {
    final all = await getAllProductsForAdmin();
    return all.where((p) => p.moderationStatus == status.toJson()).toList();
  }

  // =========================
  // GET PRODUCTS (customer dashboard, paginated)
  // =========================

  Future<List<ProductModel>> getAllProducts() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      queries: [Query.equal('active', true), Query.limit(100)],
    );

    return result.documents.map((doc) {
      return ProductModel.fromMap(doc.$id, doc.data);
    }).toList();
  }

  Future<PaginatedResponse<ProductModel>> getProductsPage({
    String? cursor,
    int limit = 20,
  }) async {
    final queries = <String>[
      Query.equal('active', true),
      Query.orderAsc('name'),
      Query.limit(limit),
    ];
    if (cursor != null) {
      queries.add(Query.cursorAfter(cursor));
    }

    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      queries: queries,
    );

    final items = result.documents
        .map((doc) => ProductModel.fromMap(doc.$id, doc.data))
        .toList();

    return PaginatedResponse(
      items: items,
      nextCursor: items.isNotEmpty ? items.last.id : null,
      hasMore: items.length >= limit,
    );
  }

  // =========================
  // GET PRODUCT BY ID
  // =========================

  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: productId,
      );
      return ProductModel.fromMap(doc.$id, doc.data);
    } catch (_) {
      return null;
    }
  }

  // =========================
  // GET PRODUCT SELLER
  // =========================

  Future<List<ProductModel>> getSellerProducts(String sellerId) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      queries: [Query.equal('sellerId', sellerId), Query.limit(5000)],
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
    required double weight,
    required int minPurchase,
    List<String> colors = const [],
    List<String> sizes = const [],
    String moderationNote = '',
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
        'active': false,
        'weight': weight,
        'minPurchase': minPurchase,
        'soldCount': 0,
        'colors': colors,
        'sizes': sizes,
        'moderationNote': moderationNote,
        'moderationStatus': 'pending',
        'moderatedBy': '',
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
    required double weight,
    required int minPurchase,
    List<String> colors = const [],
    List<String> sizes = const [],
    String moderationNote = '',
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
        'weight': weight,
        'minPurchase': minPurchase,
        'colors': colors,
        'sizes': sizes,
        'moderationNote': moderationNote,
      },
    );
  }

  // =========================
  // UPDATE MODERATION STATUS (admin only)
  // =========================

  Future<void> updateModerationStatus({
    required String productId,
    required ModerationStatus status,
    required String moderatedBy,
    String moderationNote = '',
  }) async {
    await databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.productsCollectionId,
      documentId: productId,
      data: {
        'moderationStatus': status.toJson(),
        'active': status.isActive,
        'moderatedBy': moderatedBy,
        'moderatedAt': DateTime.now().toIso8601String(),
        'moderationNote': moderationNote,
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
