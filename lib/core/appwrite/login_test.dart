//lib/core/appwrite/login_test.dart

import 'package:flutter/foundation.dart';

import '../services/auth_service_appwrite.dart';

class LoginTest {
  static Future<void> test() async {
    try {
      final data =
          await AuthServiceAppwrite().login(
        username: 'pengguna123',
        password: 'Test12345',
      );

      debugPrint(
        'LOGIN SUCCESS',
      );

      debugPrint(
        data.toString(),
      );
    } catch (e) {
      debugPrint(
        'LOGIN ERROR: $e',
      );
    }
  }
}