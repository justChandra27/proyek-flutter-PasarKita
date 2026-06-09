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
    required String role,
    required String password,
  }) async {
    try {
      final email = '${username.toLowerCase()}@pasarkita.app';

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
        queries: [Query.equal('username', username.toLowerCase())],
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
  // LOGOUT
  // =========================

  Future<void> logout() async {
    await account.deleteSession(sessionId: 'current');
  }
}
