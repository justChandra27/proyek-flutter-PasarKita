import 'package:appwrite/appwrite.dart';

import '../../data/models/review_model.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import '../models/paginated_response.dart';

class ReviewServiceAppwrite {
  final Databases databases = AppwriteService.databases;

  Future<ReviewModel> createReview({
    required String productId,
    required String orderId,
    required String userId,
    required String userName,
    required int rating,
    String? comment,
  }) async {
    final now = DateTime.now().toIso8601String();
    final doc = await databases.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.reviewsCollectionId,
      documentId: ID.unique(),
      data: {
        'productId': productId,
        'orderId': orderId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': now,
      },
    );
    return ReviewModel.fromMap(doc.data, doc.$id);
  }

  Future<List<ReviewModel>> getProductReviews(String productId) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.reviewsCollectionId,
      queries: [
        Query.equal('productId', productId),
        Query.orderDesc('createdAt'),
      ],
    );
    return result.documents
        .map((doc) => ReviewModel.fromMap(doc.data, doc.$id))
        .toList();
  }

  Future<PaginatedResponse<ReviewModel>> getProductReviewsPage({
    required String productId,
    String? cursor,
    int limit = 10,
  }) async {
    final queries = <String>[
      Query.equal('productId', productId),
      Query.orderDesc('createdAt'),
      Query.limit(limit),
    ];
    if (cursor != null) {
      queries.add(Query.cursorAfter(cursor));
    }

    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.reviewsCollectionId,
      queries: queries,
    );

    final items = result.documents
        .map((doc) => ReviewModel.fromMap(doc.data, doc.$id))
        .toList();

    return PaginatedResponse(
      items: items,
      nextCursor: items.isNotEmpty ? items.last.id : null,
      hasMore: items.length >= limit,
    );
  }

  Future<ProductReviewStats> getProductStats(String productId) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.reviewsCollectionId,
      queries: [Query.equal('productId', productId)],
    );

    if (result.documents.isEmpty) {
      return ProductReviewStats.empty();
    }

    final ratings = result.documents.map((d) => d.data['rating'] as int? ?? 0);
    final total = ratings.fold<int>(0, (sum, r) => sum + r);
    final avg = total / ratings.length;

    return ProductReviewStats(
      averageRating: double.parse(avg.toStringAsFixed(1)),
      reviewCount: ratings.length,
    );
  }

  Future<Map<String, ProductReviewStats>> getProductsStats(
      List<String> productIds) async {
    if (productIds.isEmpty) return {};

    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.reviewsCollectionId,
      queries: [Query.equal('productId', productIds)],
    );

    final grouped = <String, List<int>>{};
    for (final doc in result.documents) {
      final pid = doc.data['productId'] as String? ?? '';
      final rating = doc.data['rating'] as int? ?? 0;
      grouped.putIfAbsent(pid, () => []).add(rating);
    }

    final stats = <String, ProductReviewStats>{};
    for (final pid in productIds) {
      final ratings = grouped[pid];
      if (ratings == null || ratings.isEmpty) {
        stats[pid] = ProductReviewStats.empty();
      } else {
        final total = ratings.fold<int>(0, (s, r) => s + r);
        final avg = double.parse((total / ratings.length).toStringAsFixed(1));
        stats[pid] = ProductReviewStats(
          averageRating: avg,
          reviewCount: ratings.length,
        );
      }
    }

    return stats;
  }

  Future<bool> hasReviewed({
    required String productId,
    required String orderId,
    required String userId,
  }) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.reviewsCollectionId,
      queries: [
        Query.equal('productId', productId),
        Query.equal('orderId', orderId),
        Query.equal('userId', userId),
        Query.limit(1),
      ],
    );
    return result.documents.isNotEmpty;
  }
}
