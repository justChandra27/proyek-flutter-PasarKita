class CartModel {
  final String productId;
  final String sellerId;
  final String name;
  final int price;
  final String imageUrl;
  final int quantity;
  final int stock;
  final String selectedColor;
  final String selectedSize;

  CartModel({
    required this.productId,
    required this.sellerId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
    this.stock = 0,
    this.selectedColor = '',
    this.selectedSize = '',
  });

  factory CartModel.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return CartModel(
      productId: data['productId'] ?? documentId,
      sellerId: data['sellerId'] ?? '',
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      quantity: data['quantity'] ?? 1,
      stock: data['stock'] ?? 0,
      selectedColor: data['selectedColor'] ?? '',
      selectedSize: data['selectedSize'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'sellerId': sellerId,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'stock': stock,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }
}