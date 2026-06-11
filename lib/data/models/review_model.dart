class ReviewModel {
  final String id;
  final String productId;
  final String orderId;
  final String userId;
  final String userName;
  final int rating;
  final String? comment;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    return ReviewModel(
      id: docId,
      productId: map['productId'] ?? '',
      orderId: map['orderId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      rating: map['rating'] ?? 5,
      comment: map['comment'],
      createdAt: map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'orderId': orderId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }
}

class ProductReviewStats {
  final double averageRating;
  final int reviewCount;

  ProductReviewStats({required this.averageRating, required this.reviewCount});

  factory ProductReviewStats.empty() =>
      ProductReviewStats(averageRating: 0.0, reviewCount: 0);
}
