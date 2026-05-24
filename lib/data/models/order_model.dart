class OrderModel {

  final String id;

  final int totalPrice;

  final String status;

  OrderModel({

    required this.id,

    required this.totalPrice,

    required this.status,
  });

  factory OrderModel.fromFirestore(

    Map<String, dynamic> data,

    String documentId,

  ) {

    return OrderModel(

      id: documentId,

      totalPrice:
          data['totalPrice'] ?? 0,

      status:
          data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {

    return {

      'totalPrice': totalPrice,

      'status': status,
    };
  }
}