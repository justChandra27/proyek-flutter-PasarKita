import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/product_model.dart';

class ProductService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // GET PRODUCTS
  Future<List<ProductModel>>
      getProducts() async {

    QuerySnapshot snapshot =
        await _firestore
            .collection('products')
            .get();

    return snapshot.docs.map((doc) {

      return ProductModel.fromFirestore(

        doc.data()
            as Map<String, dynamic>,

        doc.id,
      );
    }).toList();
  }

  // ADD PRODUCT
  Future<void> addProduct(
    ProductModel product,
  ) async {

    await _firestore
        .collection('products')
        .add(

      product.toMap(),
    );
  }

  // UPDATE PRODUCT
  Future<void> updateProduct({

    required String id,

    required ProductModel product,

  }) async {

    await _firestore
        .collection('products')
        .doc(id)
        .update(

      product.toMap(),
    );
  }

  // DELETE PRODUCT
  Future<void> deleteProduct(
    String id,
  ) async {

    await _firestore
        .collection('products')
        .doc(id)
        .delete();
  }
}