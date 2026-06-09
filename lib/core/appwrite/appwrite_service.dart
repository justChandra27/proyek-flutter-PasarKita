// lib/core/appwrite/appwrite_service.dart

import 'package:appwrite/appwrite.dart';

import 'appwrite_config.dart';

class AppwriteService {
  static final Client client = Client()
      .setEndpoint(AppwriteConfig.endpoint)
      .setProject(AppwriteConfig.projectId);

  static final Account account =
      Account(client);

  static final Databases databases =
      Databases(client);

  static final Storage storage =
      Storage(client);
}