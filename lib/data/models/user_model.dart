//lib/data/models/user_model.dart

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String status;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      status: map['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'status': status,
    };
  }
}