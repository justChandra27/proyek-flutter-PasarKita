//lib/presentation/customer/customer_web_page.dart

import 'package:flutter/material.dart';

import '../auth/login_page.dart';

import 'widgets/sidebar_customer_web.dart';
import 'dashboard/dashboard_customer_web.dart';
import 'cart/cart_customer_web.dart';
import 'orders/pesanan_customer_web.dart';
import 'profile/profile_customer_web.dart';

class CustomerWebPage extends StatefulWidget {
  const CustomerWebPage({super.key});

  @override
  State<CustomerWebPage> createState() =>
      _CustomerWebPageState();
}

class _CustomerWebPageState
    extends State<CustomerWebPage> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    DashboardCustomerWeb(),
    CartCustomerWeb(),
    PesananCustomerWeb(),
    ProfileCustomerWeb(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarCustomerWeb(
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