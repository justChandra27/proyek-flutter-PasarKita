class CartModel {

  final String id;

  final String name;

  final int price;

  final String imageUrl;

  final int quantity;

  final String size;

  final String color;

  CartModel({

    required this.id,

    required this.name,

    required this.price,

    required this.imageUrl,

    required this.quantity,

    required this.size,

    required this.color,
  });

  factory CartModel.fromFirestore(

    Map<String, dynamic> data,

    String documentId,

  ) {

    return CartModel(

      id: documentId,

      name: data['name'] ?? '',

      price: data['price'] ?? 0,

      imageUrl:
          data['imageUrl'] ?? '',

      quantity:
          data['quantity'] ?? 1,

      size: data['size'] ?? '',

      color: data['color'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {

    return {

      'name': name,

      'price': price,

      'imageUrl': imageUrl,

      'quantity': quantity,

      'size': size,

      'color': color,
    };
  }
}