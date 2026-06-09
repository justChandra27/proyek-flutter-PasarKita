//lib/presentation/customer/customer_mobile_page.dart

import 'package:flutter/material.dart';

class BottomNavCustomerMobile
    extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavCustomerMobile({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor:
          const Color(0xff2563EB),
      unselectedItemColor:
          Colors.black54,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon:
              Icon(Icons.shopping_cart_outlined),
          label: "Cart",
        ),
        BottomNavigationBarItem(
          icon:
              Icon(Icons.receipt_long_outlined),
          label: "Pesanan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profil",
        ),
      ],
    );
  }
}