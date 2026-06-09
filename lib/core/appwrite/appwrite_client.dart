//lib/core/appwrite/appwrite_client.dart

import 'package:appwrite/appwrite.dart';

import 'appwrite_config.dart';

class AppwriteClient {
  static final Client client = Client()
      .setEndpoint(AppwriteConfig.endpoint)
      .setProject(AppwriteConfig.projectId);

  static final Databases databases =
      Databases(client);

  static final Account account =
      Account(client);
}