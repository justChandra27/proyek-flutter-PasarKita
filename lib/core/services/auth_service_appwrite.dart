//lib/core/services/auth_service_appwrite.dart

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';

class AuthServiceAppwrite {
  final Account account = AppwriteService.account;
  final Databases databases = AppwriteService.databases;

  // =========================
  // REGISTER
  // =========================

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String role,
    required String password,
  }) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      await databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: ID.unique(),
        data: {
          'uid': user.$id,
          'name': name,
          'email': email,
          'username': username.toLowerCase(),
          'role': role,
          'status': 'pending',
          'active': true,
          'phone': '',
          'shippingAddress': '',
          'shippingCity': '',
          'shippingProvince': '',
          'shippingPostalCode': '',
        },
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Register gagal');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // LOGIN
  // =========================

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.equal('username', username.toLowerCase()),
          Query.limit(1),
        ],
      );

      if (result.documents.isEmpty) {
        throw Exception('Username tidak ditemukan');
      }

      final userData = result.documents.first.data;

      if (userData['status'] == 'pending') {
        throw Exception('Akun menunggu verifikasi admin');
      }

      if (userData['status'] == 'rejected') {
        throw Exception('Akun ditolak admin');
      }

      await account.createEmailPasswordSession(
        email: userData['email'],
        password: password,
      );

      return userData;
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Login gagal');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // =========================
  // CURRENT USER
  // =========================

  Future<models.User> getCurrentUser() async {
    return await account.get();
  }

  // =========================
  // CHECK SESSION
  // =========================

  Future<bool> hasActiveSession() async {
    try {
      await account.get();
      return true;
    } catch (_) {
      return false;
    }
  }

  // =========================
  // CURRENT USER DATA (including role)
  // =========================

  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      final user = await account.get();
      final result = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.equal('email', user.email),
          Query.limit(1),
        ],
      );
      if (result.documents.isEmpty) return null;
      return result.documents.first.data;
    } catch (_) {
      return null;
    }
  }

  // =========================
  // UPDATE USER DATA
  // =========================

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      final user = await account.get();
      final result = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.equal('uid', user.$id),
          Query.limit(1),
        ],
      );
      if (result.documents.isEmpty) return;
      final docId = result.documents.first.$id;
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: docId,
        data: data,
      );
    } on AppwriteException catch (e) {
      throw Exception(e.message ?? 'Update profil gagal');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // LOGOUT
  // =========================

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }

  // =========================
  // PROFILE COMPLETENESS
  // =========================

  static bool isCustomerProfileComplete(Map<String, dynamic>? userData) {
    if (userData == null) return false;
    final phone = userData['phone'] as String? ?? '';
    final address = userData['shippingAddress'] as String? ?? '';
    final city = userData['shippingCity'] as String? ?? '';
    final province = userData['shippingProvince'] as String? ?? '';
    final postal = userData['shippingPostalCode'] as String? ?? '';
    return phone.isNotEmpty &&
        address.isNotEmpty &&
        city.isNotEmpty &&
        province.isNotEmpty &&
        postal.isNotEmpty;
  }

  static bool isSellerProfileComplete(Map<String, dynamic>? userData) {
    if (userData == null) return false;
    final phone = userData['phone'] as String? ?? '';
    final storeName = userData['storeName'] as String? ?? '';
    final storeAddress = userData['storeAddress'] as String? ?? '';
    return phone.isNotEmpty &&
        storeName.isNotEmpty &&
        storeAddress.isNotEmpty;
  }
}
