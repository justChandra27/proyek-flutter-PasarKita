import 'package:flutter/material.dart';

import '../core/services/auth_service_appwrite.dart';

class AuthProvider extends ChangeNotifier {
  final AuthServiceAppwrite _authService = AuthServiceAppwrite();

  bool isLoading = true;
  bool isLoggedIn = false;
  Map<String, dynamic>? currentUser;

  Future<void> checkSession() async {
    try {
      await _authService.account.get();
      currentUser = await _authService.getCurrentUserData();
      isLoggedIn = true;
    } catch (_) {
      isLoggedIn = false;
      currentUser = null;
    }
    isLoading = false;
    notifyListeners();
  }
}
