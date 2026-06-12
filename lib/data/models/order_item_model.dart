class OrderItemModel {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String sellerId;
  final int price;
  final int quantity;
  final int subtotal;
  final String imageUrl;

  OrderItemModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.sellerId,
    required this.price,
    required this.quantity,
    required this.subtotal,
    required this.imageUrl,
  });

  factory OrderItemModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return OrderItemModel(
      id: id,
      orderId: data['orderId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      sellerId: data['sellerId'] ?? '',
      price: data['price'] ?? 0,
      quantity: data['quantity'] ?? 1,
      subtotal: data['subtotal'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'sellerId': sellerId,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'imageUrl': imageUrl,
    };
  }
}
