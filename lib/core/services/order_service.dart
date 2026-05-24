import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> createOrder({

    required List<Map<String, dynamic>>
        items,

    required int totalPrice,

  }) async {

    await _firestore
        .collection('orders')
        .add({

      'items': items,

      'totalPrice': totalPrice,

      'status': 'pending',

      'createdAt':
          Timestamp.now(),
    });
  }
}