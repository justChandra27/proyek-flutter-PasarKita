import 'package:flutter/material.dart';

class BottomNavCustomerMobile
    extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadNotifCount;

  const BottomNavCustomerMobile({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadNotifCount = 0,
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
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        const BottomNavigationBarItem(
          icon:
              Icon(Icons.shopping_cart_outlined),
          label: "Cart",
        ),
        const BottomNavigationBarItem(
          icon:
              Icon(Icons.receipt_long_outlined),
          label: "Pesanan",
        ),
        BottomNavigationBarItem(
          icon: _notifIcon(),
          label: "Notifikasi",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: "Profil",
        ),
      ],
    );
  }

  Widget _notifIcon() {
    if (unreadNotifCount <= 0) {
      return const Icon(Icons.notifications_outlined);
    }
    return Badge(
      label: Text(
        unreadNotifCount > 99 ? '99+' : '$unreadNotifCount',
        style: const TextStyle(fontSize: 10),
      ),
      child: const Icon(Icons.notifications_outlined),
    );
  }
}
