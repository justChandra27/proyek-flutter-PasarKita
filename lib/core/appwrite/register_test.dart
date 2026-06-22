//lib/core/appwrite/register_test.dart

import 'package:flutter/foundation.dart';

import '../services/auth_service_appwrite.dart';

class RegisterTest {
  static Future<void> test() async {
    try {
      await AuthServiceAppwrite()
          .register(
        name: 'Test pengguna',
        username: 'pengguna123',
        email: 'pengguna123@example.com',
        role: 'seller',
        password: 'Test12345',
      );

      debugPrint(
        'REGISTER SUCCESS',
      );
    } catch (e) {
      debugPrint(
        'REGISTER ERROR: $e',
      );
    }
  }
}