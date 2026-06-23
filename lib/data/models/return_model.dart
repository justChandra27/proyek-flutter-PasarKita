class ReturnModel {
  final String id;
  final String orderId;
  final String orderItemId;
  final String customerId;
  final String sellerId;
  final String reason;
  final String description;
  final List<String> photoUrls;
  final String status;
  final String adminNote;
  final String orderCode;
  final int refundAmount;
  final String processedBy;
  final String returnDeadline;
  final String approvedAt;
  final String rejectedAt;

  ReturnModel({
    required this.id,
    required this.orderId,
    required this.orderItemId,
    required this.customerId,
    required this.sellerId,
    required this.reason,
    this.description = '',
    this.photoUrls = const [],
    required this.status,
    this.adminNote = '',
    required this.orderCode,
    this.refundAmount = 0,
    this.processedBy = '',
    this.returnDeadline = '',
    this.approvedAt = '',
    this.rejectedAt = '',
  });

  factory ReturnModel.fromMap(String id, Map<String, dynamic> data) {
    return ReturnModel(
      id: id,
      orderId: data['orderId'] ?? '',
      orderItemId: data['orderItemId'] ?? '',
      customerId: data['customerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      reason: data['reason'] ?? '',
      description: data['description'] ?? '',
      photoUrls: (data['photoUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: data['status'] ?? 'requested',
      adminNote: data['adminNote'] ?? '',
      orderCode: data['orderCode'] ?? '',
      refundAmount: data['refundAmount'] ?? 0,
      processedBy: data['processedBy'] ?? '',
      returnDeadline: data['returnDeadline'] ?? '',
      approvedAt: data['approvedAt'] ?? '',
      rejectedAt: data['rejectedAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'orderItemId': orderItemId,
      'customerId': customerId,
      'sellerId': sellerId,
      'reason': reason,
      'description': description,
      'photoUrls': photoUrls,
      'status': status,
      'adminNote': adminNote,
      'orderCode': orderCode,
      'refundAmount': refundAmount,
      'processedBy': processedBy,
      'returnDeadline': returnDeadline,
      'approvedAt': approvedAt,
      'rejectedAt': rejectedAt,
    };
  }

  ReturnModel copyWith({
    String? id,
    String? orderId,
    String? orderItemId,
    String? customerId,
    String? sellerId,
    String? reason,
    String? description,
    List<String>? photoUrls,
    String? status,
    String? adminNote,
    String? orderCode,
    int? refundAmount,
    String? processedBy,
    String? returnDeadline,
    String? approvedAt,
    String? rejectedAt,
  }) {
    return ReturnModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderItemId: orderItemId ?? this.orderItemId,
      customerId: customerId ?? this.customerId,
      sellerId: sellerId ?? this.sellerId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      orderCode: orderCode ?? this.orderCode,
      refundAmount: refundAmount ?? this.refundAmount,
      processedBy: processedBy ?? this.processedBy,
      returnDeadline: returnDeadline ?? this.returnDeadline,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
    );
  }
}
