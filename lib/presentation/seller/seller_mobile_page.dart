//lib/presentation/seller/seller_mobile_page.dart

import 'package:flutter/material.dart';

import 'dashboard/dashboard_seller_mobile.dart';
import 'products/form_produk_seller_mobile.dart';
import 'orders/form_pesanan_seller_mobile.dart';
import 'categories/form_kategori_seller_mobile.dart';
import 'profile/profile_seller_mobile.dart';

import 'widgets/bottom_nav_seller_mobile.dart';

class SellerMobilePage extends StatefulWidget {
  const SellerMobilePage({super.key});

  @override
  State<SellerMobilePage> createState() =>
      _SellerMobilePageState();
}

class _SellerMobilePageState
    extends State<SellerMobilePage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    MobileSellerDashboard(),
    FormProdukSellerMobile(),
    FormPesananSellerMobile(),
    FormKategoriSellerMobile(),
    SellerEditProfileMobile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavSellerMobile(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}