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
    );
  }
}