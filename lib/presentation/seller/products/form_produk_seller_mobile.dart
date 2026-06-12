import 'package:flutter/material.dart';

import '../profile/profile_seller_mobile.dart';

import 'widgets/product_card.dart';
import 'widgets/seller_product_builder.dart';
import 'product_form_page.dart';

class FormProdukSellerMobile extends StatefulWidget {
  const FormProdukSellerMobile({super.key});

  @override
  State<FormProdukSellerMobile> createState() => _FormProdukSellerMobileState();
}

class _FormProdukSellerMobileState extends State<FormProdukSellerMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "PasarKita",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2563EB),
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SellerEditProfileMobile(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Produk Saya",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Daftar produk toko Anda",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductFormPage(),
                            ),
                          );
                          if (result == true && mounted) {
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Tambah"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1E40AF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      _filterChip("Semua", true),
                      const SizedBox(width: 8),
                      _filterChip("Aktif", false),
                      const SizedBox(width: 8),
                      _filterChip("Stok Habis", false),
                      const SizedBox(width: 8),
                      _filterChip("Arsip", false),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: SellerProductBuilder(
                builder: (context, products) {
                  if (products.isEmpty) {
                    return const Center(child: Text("Belum ada produk"));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: products[index],
                        onProductChanged: () {
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xff1E40AF) : const Color(0xffDBEAFE),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: active ? Colors.white : Colors.black54,
          fontWeight: active ? FontWeight.bold : null,
        ),
      ),
    );
  }
}
