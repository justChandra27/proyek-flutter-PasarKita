import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart';

import 'success_page.dart';
import '../../providers/cart_provider.dart';
import '../../core/constants/fee_config.dart';
import '../../core/services/auth_service_appwrite.dart';
import '../../core/services/order_service_appwrite.dart';
import '../../core/services/product_service_appwrite.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();
  final _orderService = OrderServiceAppwrite();
  bool _loading = false;
  String _selectedPayment = 'Transfer Bank';

  final _paymentMethods = [
    {'label': 'Kartu Kredit', 'icon': Icons.credit_card},
    {'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'label': 'E-Wallet', 'icon': Icons.wallet},
  ];

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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

  Future<void> _onBayarSekarang() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi alamat pengiriman')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final account = await AuthServiceAppwrite().getCurrentUser();
      final cart = context.read<CartProvider>();

      if (cart.items.isEmpty) {
        throw Exception('Keranjang kosong');
      }

      final productService = ProductServiceAppwrite();
      for (final cartItem in cart.items) {
        final product = await productService.getProductById(cartItem.productId);
        if (product == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Produk tidak ditemukan. Silakan periksa kembali keranjang Anda.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => _loading = false);
          return;
        }
        if (!product.active) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${product.name} tidak tersedia. Produk telah dinonaktifkan.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _loading = false);
          return;
        }
        if (cartItem.quantity > product.stock) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Stok produk berubah. Silakan periksa kembali keranjang Anda.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          setState(() => _loading = false);
          return;
        }
      }

      final items = cart.items.map((item) {
        final subtotal = item.price * item.quantity;
        return {
          'productId': item.productId,
          'productName': item.name,
          'sellerId': item.sellerId,
          'price': item.price,
          'quantity': item.quantity,
          'subtotal': subtotal,
          'imageUrl': item.imageUrl,
          'selectedColor': item.selectedColor,
          'selectedSize': item.selectedSize,
        };
      }).toList();

      final orderId = await _orderService.createOrder(
        customerId: account.$id,
        customerName: account.name,
        customerEmail: account.email,
        address: address,
        paymentMethod: _selectedPayment,
        items: items,
      );

      final orderItems = cart.items.map((item) {
        return {
          'productId': item.productId,
          'productName': item.name,
          'price': item.price,
          'quantity': item.quantity,
          'subtotal': item.price * item.quantity,
          'imageUrl': item.imageUrl,
          'selectedColor': item.selectedColor,
          'selectedSize': item.selectedSize,
        };
      }).toList();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessPage(
            orderId: orderId,
            customerName: account.name,
            address: address,
            paymentMethod: _selectedPayment,
            totalAmount: cart.totalPrice,
            items: orderItems,
          ),
        ),
      );
    } on AppwriteException catch (e) {
      if (!mounted) return;
      if (e.type == 'insufficient_stock') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Stok tidak mencukupi'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: ${e.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat pesanan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 768;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _leftColumn(cart)),
                      const SizedBox(width: 24),
                      Expanded(flex: 2, child: _rightColumn(cart)),
                    ],
                  )
                : Column(
                    children: [
                      _leftColumn(cart),
                      const SizedBox(height: 24),
                      _rightColumn(cart),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _leftColumn(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Alamat Pengiriman'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Alamat Lengkap',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Masukkan alamat lengkap pengiriman',
                  filled: true,
                  fillColor: const Color(0xffF1F5F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _sectionTitle('Metode Pembayaran'),
        const SizedBox(height: 12),
        ..._paymentMethods.map((method) {
          final label = method['label'] as String;
          final icon = method['icon'] as IconData;
          final selected = _selectedPayment == label;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedPayment = label),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xffEFF6FF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? const Color(0xff2563EB)
                        : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: selected
                          ? const Color(0xff2563EB)
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: selected
                              ? const Color(0xff2563EB)
                              : Colors.black87,
                        ),
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xff2563EB),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _rightColumn(CartProvider cart) {
    final total = cart.totalPrice;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Ringkasan Belanja'),
          const SizedBox(height: 16),
          if (cart.items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Tidak ada item')),
            )
          else
            ...cart.items.map((item) {
              final subtotal = item.price * item.quantity;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: item.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.image, color: Colors.grey),
                              ),
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.quantity} x ${_formatPrice(item.price)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatPrice(subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2563EB),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                _formatPrice(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ongkos Kirim',
                style: TextStyle(color: Colors.grey),
              ),
              const Text(
                'Gratis',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Biaya Layanan',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                _formatPrice(FeeConfig.serviceFee),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Tagihan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                _formatPrice(total + FeeConfig.serviceFee),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color(0xff2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loading ? null : _onBayarSekarang,
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Bayar Sekarang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
