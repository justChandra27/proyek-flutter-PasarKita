//lib/core/services/storage_service_appwrite.dart

import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';

import '../appwrite/appwrite_config.dart';
import '../appwrite/appwrite_service.dart';

class StorageServiceAppwrite {
  final Storage storage =
      AppwriteService.storage;

  // =========================
  // UPLOAD IMAGE
  // =========================

  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      print('UPLOAD START');

      final result =
          await storage.createFile(
        bucketId:
            AppwriteConfig.productBucketId,
        fileId: ID.unique(),
        file: InputFile.fromBytes(
          bytes: bytes,
          filename: fileName,
        ),
      );

      print('UPLOAD SUCCESS');
      print(result.$id);

      return result.$id;
    } catch (e) {
      print('UPLOAD ERROR');
      print(e);

      rethrow;
    }
  }

  // =========================
  // GET IMAGE URL
  // =========================

  String getImageUrl(
    String fileId,
  ) {
    return '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.productBucketId}/files/$fileId/view?project=${AppwriteConfig.projectId}';
  }

  // =========================
  // EXTRACT FILE ID FROM URL
  // =========================

  String extractFileId(
    String imageUrl,
  ) {
    final uri = Uri.parse(imageUrl);

    final segments =
        uri.pathSegments;

    final index =
        segments.indexOf('files');

    if (index == -1 ||
        index + 1 >= segments.length) {
      throw Exception(
        'File ID tidak ditemukan pada URL',
      );
    }

    return segments[index + 1];
  }

  // =========================
  // DELETE IMAGE
  // =========================

  Future<void> deleteImage(
    String fileId,
  ) async {
    try {
      await storage.deleteFile(
        bucketId:
            AppwriteConfig.productBucketId,
        fileId: fileId,
      );

      print(
        'DELETE IMAGE SUCCESS',
      );
    } catch (e) {
      print(
        'DELETE IMAGE ERROR',
      );
      print(e);

      rethrow;
    }
  }
}