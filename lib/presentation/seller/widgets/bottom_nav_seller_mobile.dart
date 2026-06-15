//lib/presentation/seller/widgets/bottom_nav_seller_mobile.dart

import 'package:flutter/material.dart';

class BottomNavSellerMobile extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavSellerMobile({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xffE5E7EB),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: "Dashboard",
            index: 0,
          ),
          _navItem(
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2,
            label: "Produk Saya",
            index: 1,
          ),
          _navItem(
            icon: Icons.shopping_cart_outlined,
            activeIcon: Icons.shopping_cart,
            label: "Pesanan",
            index: 2,
          ),
          _navItem(
            icon: Icons.category_outlined,
            activeIcon: Icons.category,
            label: "Kategori",
            index: 3,
          ),
          _navItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: "Profil",
            index: 4,
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool active = currentIndex == index;

    return InkWell(
      borderRadius:
          BorderRadius.circular(18),
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: active ? 18 : 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xff1E40AF)
              : Colors.transparent,
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active
                  ? Colors.white
                  : Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: active
                    ? Colors.white
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}