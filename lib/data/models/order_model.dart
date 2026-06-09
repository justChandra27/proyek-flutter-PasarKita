//firebase

class OrderModel {
  final String id;
  final String orderCode;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final int totalAmount;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String address;
  final String notes;
  final String createdAt;
  final String updatedAt;

  OrderModel({
    required this.id,
    required this.orderCode,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.address,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return OrderModel(
      id: id,
      orderCode: data['orderCode'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerEmail: data['customerEmail'] ?? '',
      totalAmount: data['totalAmount'] ?? 0,
      status: data['status'] ?? 'Pending',
      paymentMethod: data['paymentMethod'] ?? '',
      paymentStatus: data['paymentStatus'] ?? '',
      address: data['address'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: data['createdAt'] ?? '',
      updatedAt: data['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderCode': orderCode,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'address': address,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}