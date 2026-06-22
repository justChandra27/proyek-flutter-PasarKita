import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart';

import 'success_page.dart';
import '../../providers/cart_provider.dart';
import '../../core/constants/fee_config.dart';
import '../../core/services/auth_service_appwrite.dart';
import '../../core/services/bank_service.dart';
import '../../core/services/email_service_appwrite.dart';
import '../../core/services/order_service_appwrite.dart';
import '../../core/services/product_service_appwrite.dart';
import '../../data/models/bank_model.dart';
import '../../data/models/cart_model.dart';
import '../customer/customer_page.dart';

class CheckoutPage extends StatefulWidget {
  final CartModel? buyNowItem;

  const CheckoutPage({super.key, this.buyNowItem});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _senderNameController = TextEditingController();
  final _orderService = OrderServiceAppwrite();
  final _bankService = BankService();
  bool _loading = false;
  bool _banksLoading = true;
  List<BankModel> _banks = [];
  BankModel? _selectedBank;

  String _profileShippingAddress = '';
  String _profileShippingCity = '';
  String _profileShippingProvince = '';
  String _profileShippingPostalCode = '';
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
      _loadBanks();
    });
  }

  Future<void> _loadBanks() async {
    try {
      final banks = await _bankService.getBanks();
      if (mounted) setState(() { _banks = banks; _banksLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _banksLoading = false; });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final data = await AuthServiceAppwrite().getCurrentUserData();
      if (!mounted) return;
      if (data != null) {
        final address = data['shippingAddress'] ?? '';
        final city = data['shippingCity'] ?? '';
        final province = data['shippingProvince'] ?? '';
        final postal = data['shippingPostalCode'] ?? '';
        final phone = data['phone'] ?? '';

        final parts = [address, city, province, postal].where((p) => p.isNotEmpty);
        final combined = parts.join(', ');

        setState(() {
          _userData = data;
          _addressController.text = combined.isNotEmpty ? combined : '';
          _phoneController.text = phone;
          _profileShippingAddress = address;
          _profileShippingCity = city;
          _profileShippingProvince = province;
          _profileShippingPostalCode = postal;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _senderNameController.dispose();
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

    if (_selectedBank == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih bank tujuan')),
      );
      return;
    }

    final senderName = _senderNameController.text.trim();
    if (senderName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi nama pengirim transfer')),
      );
      return;
    }

    if (!AuthServiceAppwrite.isCustomerProfileComplete(_userData)) {
      final shouldGo = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Profil Belum Lengkap'),
          content: const Text(
            'Lengkapi profil terlebih dahulu sebelum melakukan checkout.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Lengkapi Profil'),
            ),
          ],
        ),
      );

      if (shouldGo == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerPage(initialIndex: 4),
          ),
          (route) => false,
        );
      }
      return;
    }

    setState(() => _loading = true);

    try {
      final account = await AuthServiceAppwrite().getCurrentUser();
      final isBuyNow = widget.buyNowItem != null;

      List<CartModel> checkoutItems;
      int totalPrice;

      if (isBuyNow) {
        checkoutItems = [widget.buyNowItem!];
        totalPrice = widget.buyNowItem!.price;
      } else {
        final cart = context.read<CartProvider>();
        if (cart.items.isEmpty) {
          throw Exception('Keranjang kosong');
        }
        checkoutItems = cart.items;
        totalPrice = cart.totalPrice;
      }

      final productService = ProductServiceAppwrite();
      for (final cartItem in checkoutItems) {
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

      final items = checkoutItems.map((item) {
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

      final orderCode = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      final orderId = await _orderService.createOrder(
        customerId: account.$id,
        customerName: account.name,
        customerEmail: account.email,
        address: address,
        paymentMethod: 'Transfer Bank',
        orderCode: orderCode,
        items: items,
        phone: _phoneController.text.trim(),
        shippingAddress: _profileShippingAddress,
        shippingCity: _profileShippingCity,
        shippingProvince: _profileShippingProvince,
        shippingPostalCode: _profileShippingPostalCode,
        bankName: _selectedBank!.name,
        senderName: senderName,
      );

      final orderItems = checkoutItems.map((item) {
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

      if (!isBuyNow) {
        context.read<CartProvider>().clear();
      }

      // Email tidak boleh menjadi blocker checkout
      unawaited(
        EmailServiceAppwrite().sendReceiptEmail(
          orderId: orderId,
          orderCode: orderCode,
          customerName: account.name,
          customerEmail: account.email,
          items: orderItems,
          subtotal: totalPrice,
          total: totalPrice + FeeConfig.serviceFee,
          shippingCost: 0,
          orderDate: DateTime.now().toIso8601String(),
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SuccessPage(
            orderId: orderId,
            customerName: account.name,
            address: address,
            paymentMethod: 'Transfer Bank',
            totalAmount: totalPrice,
            items: orderItems,
            bankName: _selectedBank!.name,
            bankAccountNumber: _selectedBank!.accountNumber,
            bankAccountName: _selectedBank!.accountName,
            senderName: senderName,
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
    final isBuyNow = widget.buyNowItem != null;
    final cart = isBuyNow ? null : context.watch<CartProvider>();
    final checkoutItems = isBuyNow ? [widget.buyNowItem!] : (cart?.items ?? []);
    final totalPrice = isBuyNow ? widget.buyNowItem!.price : (cart?.totalPrice ?? 0);

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
                      Expanded(flex: 3, child: _leftColumn()),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: _rightColumn(
                          items: checkoutItems,
                          totalPrice: totalPrice,
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _leftColumn(),
                      const SizedBox(height: 24),
                      _rightColumn(
                        items: checkoutItems,
                        totalPrice: totalPrice,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _leftColumn() {
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
        const SizedBox(height: 16),
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
                  const Icon(Icons.phone_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Nomor Telepon',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Masukkan nomor telepon',
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
        const SizedBox(height: 8),
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
                  const Icon(Icons.account_balance, size: 20, color: Color(0xff2563EB)),
                  const SizedBox(width: 8),
                  const Text(
                    'Transfer Bank',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_banksLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ))
              else if (_banks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Belum ada bank tersedia', style: TextStyle(color: Colors.grey)),
                )
              else
                ..._banks.map((bank) {
                  final selected = _selectedBank?.id == bank.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedBank = bank),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xffEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? const Color(0xff2563EB) : Colors.grey.shade200,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bank.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: selected ? const Color(0xff2563EB) : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${bank.accountNumber} a.n. ${bank.accountName}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check_circle, color: Color(0xff2563EB)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 16),
              const Text(
                'Nama Pengirim Transfer',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _senderNameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama pengirim sesuai rekening',
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
      ],
    );
  }

  Widget _rightColumn({
    required List<CartModel> items,
    required int totalPrice,
  }) {
    final total = totalPrice;
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
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Tidak ada item')),
            )
          else
            ...items.map((item) {
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
