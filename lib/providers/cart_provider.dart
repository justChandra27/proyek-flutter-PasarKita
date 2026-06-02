import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {

  final List<Map<String, dynamic>> _items = [];

  List<Map<String, dynamic>> get items => _items;

  void addItem({

    required String name,
    required String image,
    required String price,
  }) {

    _items.add({

      "name": name,
      "image": image,
      "price": price,
    });

    notifyListeners();
  }

  void removeItem(int index) {

    _items.removeAt(index);

    notifyListeners();
  }

  int get totalItems => _items.length;
}