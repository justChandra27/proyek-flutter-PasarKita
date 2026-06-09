import 'package:flutter/material.dart';

import '../../core/services/cart_service.dart';
import '../../data/models/cart_model.dart';
import '../../core/services/order_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();

  final OrderService _orderService = OrderService();

  late Future<List<CartModel>> cartItems;

  @override
  void initState() {
    super.initState();

    cartItems = _cartService.getCartItems();
  }

  void refreshCart() {
    setState(() {
      cartItems = _cartService.getCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),

      body: FutureBuilder<List<CartModel>>(
        future: cartItems,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Keranjang kosong'));
          }

          final cartList = snapshot.data!;

          double totalPrice = 0;

          for (var cart in cartList) {
            totalPrice += cart.price * cart.quantity;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartList.length,

                  itemBuilder: (context, index) {
                    final cart = cartList[index];

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          // PRODUCT IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),

                            child: Image.network(
                              cart.imageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // PRODUCT INFO
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  cart.name,

                                  style: const TextStyle(
                                    fontSize: 20,

                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text('Rp ${cart.price}'),

                                const SizedBox(height: 6),

                                Text('Ukuran: ${cart.size}'),

                                Text('Warna: ${cart.color}'),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    // MINUS
                                    GestureDetector(
                                      onTap: () async {
                                        if (cart.quantity > 1) {
                                          await _cartService.updateQuantity(
                                            documentId: cart.id,

                                            quantity: cart.quantity - 1,
                                          );

                                          refreshCart();
                                        }
                                      },

                                      child: Container(
                                        padding: const EdgeInsets.all(6),

                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade800,

                                          shape: BoxShape.circle,
                                        ),

                                        child: const Icon(
                                          Icons.remove,
                                          size: 16,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    Text(
                                      cart.quantity.toString(),

                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,

                                        fontSize: 16,
                                      ),
                                    ),

                                    const SizedBox(width: 14),

                                    // PLUS
                                    GestureDetector(
                                      onTap: () async {
                                        await _cartService.updateQuantity(
                                          documentId: cart.id,

                                          quantity: cart.quantity + 1,
                                        );

                                        refreshCart();
                                      },

                                      child: Container(
                                        padding: const EdgeInsets.all(6),

                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade800,

                                          shape: BoxShape.circle,
                                        ),

                                        child: const Icon(Icons.add, size: 16),
                                      ),
                                    ),

                                    const Spacer(),

                                    // DELETE
                                    GestureDetector(
                                      onTap: () async {
                                        await _cartService.removeCartItem(
                                          cart.id,
                                        );

                                        refreshCart();
                                      },

                                      child: const Icon(
                                        Icons.delete,

                                        color: Colors.red,

                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                Align(
                                  alignment: Alignment.centerRight,

                                  child: Text(
                                    'Rp ${cart.price * cart.quantity}',

                                    style: const TextStyle(
                                      color: Color(0xFFD4AF37),

                                      fontSize: 18,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // TOTAL CHECKOUT
              Container(
                padding: const EdgeInsets.all(20),

                decoration: const BoxDecoration(color: Color(0xFF1E1E1E)),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text(
                      'Total: Rp ${totalPrice.toInt()}',

                      style: const TextStyle(
                        fontSize: 20,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    ElevatedButton(
                      onPressed: () async {
                        List<Map<String, dynamic>> orderItems = [];

                        for (var cart in cartList) {
                          orderItems.add({
                            'name': cart.name,

                            'price': cart.price,

                            'quantity': cart.quantity,

                            'size': cart.size,

                            'color': cart.color,

                            'imageUrl': cart.imageUrl,
                          });
                        }

                        await _orderService.createOrder(
                          items: orderItems,

                          totalPrice: totalPrice.toInt(),
                        );

                        await _cartService.clearCart();

                        refreshCart();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Checkout berhasil')),
                        );
                      },

                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
