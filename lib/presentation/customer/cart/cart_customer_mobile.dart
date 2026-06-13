//lib/presentation/customer/cart/cart_customer_mobile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/cart_model.dart';
import '../../../providers/cart_provider.dart';
import '../../checkout/checkout_page.dart';

class CartCustomerMobile extends StatelessWidget {
  const CartCustomerMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return const Center(child: Text("Keranjang kosong"));
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Keranjang Saya",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Anda memiliki ${cart.itemCount} item dalam keranjang",
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      TextButton(
                        onPressed: cart.clear,
                        child: const Text(
                          "Bersihkan Keranjang",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ...cart.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(
                          bottom: 12),
                      child: _cartItem(context, item),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Catatan Pesanan",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          maxLines: 3,
                          decoration:
                              InputDecoration(
                            hintText:
                                "Contoh: Titip di satpam ya...",
                            filled: true,
                            fillColor:
                                const Color(0xffF5F7FB),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                              borderSide:
                                  BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffEAF1FF),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Align(
                          alignment:
                              Alignment.centerLeft,
                          child: Text(
                            "Ringkasan Belanja",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _summaryRow(
                          "Subtotal (${cart.itemCount} item)",
                          _formatPrice(cart.totalPrice),
                        ),

                        const SizedBox(height: 8),

                        _summaryRow(
                          "Biaya Pengiriman",
                          "GRATIS",
                          valueColor: Colors.green,
                        ),

                        const SizedBox(height: 8),

                        _summaryRow(
                          "Biaya Layanan",
                          "Rp 2.000",
                        ),

                        const Divider(height: 30),

                        Row(
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const Spacer(),

                            Text(
                              _formatPrice(
                                  cart.totalPrice + 2000),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(0xff2563EB),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton
                                .styleFrom(
                              backgroundColor:
                                  const Color(
                                      0xff2563EB),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                        12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CheckoutPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Checkout Sekarang",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatPrice(int price) {
    final p = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

  Widget _cartItem(
      BuildContext context, CartModel item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: item.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, _, _) =>
                              const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.black54,
                      ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    if (item.selectedColor.isNotEmpty ||
                        item.selectedSize.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          [
                            if (item.selectedColor.isNotEmpty)
                              item.selectedColor,
                            if (item.selectedSize.isNotEmpty)
                              item.selectedSize,
                          ].join(' / '),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    Text(
                      _formatPrice(item.price),
                      style: const TextStyle(
                        color: Color(0xff2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xffEEF3FF),
                  borderRadius:
                      BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context
                          .read<CartProvider>()
                          .updateQuantity(
                            item.productId,
                            item.quantity - 1,
                            selectedColor: item.selectedColor,
                            selectedSize: item.selectedSize,
                          ),
                      icon: const Icon(Icons.remove),
                    ),

                    Text(
                      "${item.quantity}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        if (item.quantity >= item.stock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jumlah melebihi stok tersedia.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        context
                            .read<CartProvider>()
                            .updateQuantity(
                              item.productId,
                              item.quantity + 1,
                              selectedColor: item.selectedColor,
                              selectedSize: item.selectedSize,
                            );
                      },
                      icon: Icon(
                        Icons.add,
                        color: item.quantity >= item.stock
                            ? Colors.grey
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              TextButton.icon(
                onPressed: () => context
                    .read<CartProvider>()
                    .removeItem(item.productId,
                        selectedColor: item.selectedColor,
                        selectedSize: item.selectedSize),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 18,
                ),
                label: const Text(
                  "Hapus",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    Color valueColor = Colors.black87,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
