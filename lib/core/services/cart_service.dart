import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/cart_model.dart';
import '../../data/models/product_model.dart';

class CartService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ADD TO CART
  Future<void> addToCart({

    required ProductModel product,

    required String size,

    required String color,

    required int quantity,

  }) async {

    await _firestore.collection('carts').add({

      'name': product.name,

      'price': product.price,

      'imageUrl': product.imageUrl,

      'quantity': quantity,

      'size': size,

      'color': color,
    });
  }

  // GET CART ITEMS
  Future<List<CartModel>> getCartItems() async {

    QuerySnapshot snapshot =
        await _firestore
            .collection('carts')
            .get();

    return snapshot.docs.map((doc) {

      return CartModel.fromFirestore(

        doc.data() as Map<String, dynamic>,

        doc.id,
      );
    }).toList();
  }

  // REMOVE CART ITEM
  Future<void> removeCartItem(
    String documentId,
  ) async {

    await _firestore
        .collection('carts')
        .doc(documentId)
        .delete();
  }

  // UPDATE QUANTITY
  Future<void> updateQuantity({

    required String documentId,

    required int quantity,

  }) async {

    await _firestore
        .collection('carts')
        .doc(documentId)
        .update({

      'quantity': quantity,
    });
  }

  // CLEAR CART
  Future<void> clearCart() async {

    QuerySnapshot snapshot =
        await _firestore
            .collection('carts')
            .get();

    for (var doc in snapshot.docs) {

      await doc.reference.delete();
    }
  }
}