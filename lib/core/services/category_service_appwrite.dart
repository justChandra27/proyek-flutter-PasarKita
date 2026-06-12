//lib/core/services/category_service_appwrite.dart

import 'package:appwrite/appwrite.dart';

import '../../data/models/category_model.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';

class CategoryServiceAppwrite {
  final Databases databases = AppwriteService.databases;

  Future<List<CategoryModel>> getAllCategories() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.categoriesCollectionId,
    );

    return result.documents
        .map((doc) => CategoryModel.fromMap(doc.data, doc.$id))
        .toList();
  }
}
