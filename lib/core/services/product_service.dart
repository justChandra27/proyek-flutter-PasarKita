//lib/core/services/product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/product_model.dart';

class ProductService {
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  // =========================
  // GET PRODUCT SELLER
  // =========================

  Stream<List<ProductModel>> getSellerProducts(
    String sellerId,
  ) {
    return firestore
        .collection('products')
        .where(
          'sellerId',
          isEqualTo: sellerId,
        )
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // =========================
  // ADD PRODUCT
  // =========================

  Future<void> addProduct({
    required String name,
    required String category,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
  }) async {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    await firestore.collection('products').add({
      'sellerId': uid,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'active': true,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  // =========================
  // UPDATE PRODUCT
  // =========================

  Future<void> updateProduct({
    required String productId,
    required String name,
    required String category,
    required String description,
    required double price,
    required int stock,
    required String imageUrl,
    required bool active,
  }) async {
    await firestore
        .collection('products')
        .doc(productId)
        .update({
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'active': active,
      'updatedAt': Timestamp.now(),
    });
  }

  // =========================
  // DELETE PRODUCT
  // =========================

  Future<void> deleteProduct(
    String productId,
  ) async {
    await firestore
        .collection('products')
        .doc(productId)
        .delete();
  }
}