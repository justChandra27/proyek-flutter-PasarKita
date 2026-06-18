//lib/data/models/user_model.dart

class UserModel {
  final String documentId;
  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;
  final String storeName;
  final String storeAddress;
  final String city;
  final String province;
  final String phone;
  final String shippingAddress;
  final String shippingCity;
  final String shippingProvince;
  final String shippingPostalCode;
  final String receiptEmail;
  final bool receiveReceipt;

  UserModel({
    required this.documentId,
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.storeName,
    required this.storeAddress,
    required this.city,
    required this.province,
    this.phone = '',
    this.shippingAddress = '',
    this.shippingCity = '',
    this.shippingProvince = '',
    this.shippingPostalCode = '',
    this.receiptEmail = '',
    this.receiveReceipt = false,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return UserModel(
      documentId: documentId,
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      status: map['status'] ?? 'pending',
      storeName: map['storeName'] ?? '',
      storeAddress: map['storeAddress'] ?? '',
      city: map['city'] ?? '',
      province: map['province'] ?? '',
      phone: map['phone'] ?? '',
      shippingAddress: map['shippingAddress'] ?? '',
      shippingCity: map['shippingCity'] ?? '',
      shippingProvince: map['shippingProvince'] ?? '',
      shippingPostalCode: map['shippingPostalCode'] ?? '',
      receiptEmail: map['receiptEmail'] ?? '',
      receiveReceipt: map['receiveReceipt'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'shippingAddress': shippingAddress,
      'shippingCity': shippingCity,
      'shippingProvince': shippingProvince,
      'shippingPostalCode': shippingPostalCode,
      'receiptEmail': receiptEmail,
      'receiveReceipt': receiveReceipt,
    };
  }
}