import 'package:flutter/foundation.dart';
import '../data/models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartModel> _items = [];

  List<CartModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  void addItem(CartModel item) {
    final index = _items.indexWhere(
      (i) =>
          i.productId == item.productId &&
          i.selectedColor == item.selectedColor &&
          i.selectedSize == item.selectedSize,
    );
    if (index >= 0) {
      final newQty = _items[index].quantity + item.quantity;
      if (newQty > _items[index].stock) return;
      _items[index] = CartModel(
        productId: _items[index].productId,
        sellerId: _items[index].sellerId,
        name: _items[index].name,
        price: _items[index].price,
        imageUrl: _items[index].imageUrl,
        quantity: newQty,
        stock: _items[index].stock,
        selectedColor: _items[index].selectedColor,
        selectedSize: _items[index].selectedSize,
      );
    } else {
      if (item.stock <= 0) return;
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(
    String productId, {
    String selectedColor = '',
    String selectedSize = '',
  }) {
    _items.removeWhere(
      (i) =>
          i.productId == productId &&
          i.selectedColor == selectedColor &&
          i.selectedSize == selectedSize,
    );
    notifyListeners();
  }

  void updateQuantity(
    String productId,
    int quantity, {
    String selectedColor = '',
    String selectedSize = '',
  }) {
    final index = _items.indexWhere(
      (i) =>
          i.productId == productId &&
          i.selectedColor == selectedColor &&
          i.selectedSize == selectedSize,
    );
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        final capped = quantity > _items[index].stock
            ? _items[index].stock
            : quantity;
        _items[index] = CartModel(
          productId: _items[index].productId,
          sellerId: _items[index].sellerId,
          name: _items[index].name,
          price: _items[index].price,
          imageUrl: _items[index].imageUrl,
          quantity: capped,
          stock: _items[index].stock,
          selectedColor: _items[index].selectedColor,
          selectedSize: _items[index].selectedSize,
        );
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}