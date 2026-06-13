import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartModel> _items = [];

  List<CartModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  int get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cart_items');
    if (raw == null) return;
    final list = jsonDecode(raw) as List;
    _items = list.map((e) => CartModel.fromMap(e, '')).toList();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _items.map((e) => e.toMap()).toList();
    await prefs.setString('cart_items', jsonEncode(json));
  }

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
    _saveCart();
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
    _saveCart();
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
      _saveCart();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _saveCart();
  }
}
