import 'package:appwrite/appwrite.dart';

import '../../data/models/notification_model.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';
import '../models/paginated_response.dart';

class NotificationServiceAppwrite {
  final Databases databases = AppwriteService.databases;

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    required String orderId,
  }) async {
    await databases.createDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.notificationsCollectionId,
      documentId: ID.unique(),
      data: {
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'orderId': orderId,
        'isRead': false,
        'createdAt': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<List<NotificationModel>> getNotifications(
    String userId,
  ) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.notificationsCollectionId,
      queries: [
        Query.equal('userId', userId),
        Query.orderDesc('createdAt'),
      ],
    );

    return result.documents.map((doc) {
      return NotificationModel.fromMap(doc.$id, doc.data);
    }).toList();
  }

  Future<PaginatedResponse<NotificationModel>> getNotificationsPage({
    required String userId,
    String? cursor,
    int limit = 20,
  }) async {
    final queries = <String>[
      Query.equal('userId', userId),
      Query.orderDesc('createdAt'),
      Query.limit(limit),
    ];
    if (cursor != null) {
      queries.add(Query.cursorAfter(cursor));
    }

    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.notificationsCollectionId,
      queries: queries,
    );

    final items = result.documents
        .map((doc) => NotificationModel.fromMap(doc.$id, doc.data))
        .toList();

    return PaginatedResponse(
      items: items,
      nextCursor: items.isNotEmpty ? items.last.id : null,
      hasMore: items.length >= limit,
    );
  }

  Future<int> getUnreadCount(String userId) async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.notificationsCollectionId,
      queries: [
        Query.equal('userId', userId),
        Query.equal('isRead', false),
        Query.limit(1),
      ],
    );
    return result.total;
  }

  Future<void> markAsRead(String notificationId) async {
    await databases.updateDocument(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.notificationsCollectionId,
      documentId: notificationId,
      data: {'isRead': true},
    );
  }

  Future<void> markAllAsRead(String userId) async {
    final unread = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.notificationsCollectionId,
      queries: [
        Query.equal('userId', userId),
        Query.equal('isRead', false),
      ],
    );
    for (final doc in unread.documents) {
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.notificationsCollectionId,
        documentId: doc.$id,
        data: {'isRead': true},
      );
    }
  }
}
