import 'package:appwrite/appwrite.dart';

import '../../data/models/bank_model.dart';
import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';

class BankService {
  final Databases databases = AppwriteService.databases;

  Future<List<BankModel>> getBanks() async {
    final result = await databases.listDocuments(
      databaseId: AppwriteConfig.databaseId,
      collectionId: AppwriteConfig.banksCollectionId,
    );
    return result.documents.map((doc) {
      return BankModel.fromMap(doc.$id, doc.data);
    }).toList();
  }
}
