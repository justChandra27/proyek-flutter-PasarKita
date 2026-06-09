// lib/core/appwrite/appwrite_test.dart

import 'package:flutter/foundation.dart';

import 'appwrite_service.dart';
import 'appwrite_config.dart';

class AppwriteTest {
  static Future<void> testConnection() async {
    try {
      final result =
          await AppwriteService.databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
      );

      debugPrint(
        'APPWRITE CONNECTED',
      );

      debugPrint(
        'TOTAL USERS: ${result.total}',
      );
    } catch (e) {
      debugPrint(
        'APPWRITE ERROR: $e',
      );
    }
  }
}