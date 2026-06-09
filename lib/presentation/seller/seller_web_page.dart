//lib/presentation/seller/seller_web_page.dart

import 'package:flutter/material.dart';

import 'widgets/sidebar_seller_web.dart';

import 'dashboard/dashboard_seller_web.dart';
import 'products/form_produk_seller_web.dart';
import 'orders/form_pesanan_seller_web.dart';
import 'categories/form_kategori_seller_web.dart';

import '../auth/login_page.dart';

class SellerWebPage extends StatefulWidget {
  const SellerWebPage({super.key});

  @override
  State<SellerWebPage> createState() =>
      _SellerWebPageState();
}

class _SellerWebPageState
    extends State<SellerWebPage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const DashboardSellerWeb(),
    const FormProdukSellerWeb(),
    const FormPesananSellerWeb(),
    const FormKategoriSellerWeb(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarSellerWeb(
            selectedIndex: selectedIndex,

            onMenuSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },

            onLogout: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const LoginPage(),
                ),
                (route) => false,
              );
            },
          ),

          Expanded(
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }
}