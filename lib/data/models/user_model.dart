//lib/data/models/user_model.dart

class UserModel {
  final String documentId;
  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;

  UserModel({
    required this.documentId,
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
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
    );
  }
}