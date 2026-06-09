//lib/presentation/customer/customer_mobile_page.dart

import 'package:flutter/material.dart';

import 'dashboard/dashboard_customer_mobile.dart';
import 'cart/cart_customer_mobile.dart';
import 'orders/pesanan_customer_mobile.dart';
import 'profile/profile_customer_mobile.dart';

import 'widgets/bottom_nav_customer_mobile.dart';

class CustomerMobilePage
    extends StatefulWidget {
  const CustomerMobilePage({super.key});

  @override
  State<CustomerMobilePage> createState() =>
      _CustomerMobilePageState();
}

class _CustomerMobilePageState
    extends State<CustomerMobilePage> {
  int selectedIndex = 0;

  final pages = const [
    DashboardCustomerMobile(),
    CartCustomerMobile(),
    PesananCustomerMobile(),
    ProfileCustomerMobile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],

      bottomNavigationBar:
          BottomNavCustomerMobile(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}