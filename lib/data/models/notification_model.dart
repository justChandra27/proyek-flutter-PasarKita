class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String orderId;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.orderId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return NotificationModel(
      id: id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      orderId: data['orderId'] ?? '',
      isRead: data['isRead'] ?? false,
      createdAt: data['\$createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'orderId': orderId,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
