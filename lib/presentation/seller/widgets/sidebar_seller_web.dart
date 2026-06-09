//lib/presentation/seller/widgets/sidebar_seller_web.dart

import 'package:flutter/material.dart';

class SidebarSellerWeb extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const SidebarSellerWeb({
    super.key,
    required this.selectedIndex,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "PasarKita",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2563EB),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF5F7FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150",
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Andi Setiawan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Verified Merchant",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _menu(
            index: 0,
            icon: Icons.dashboard_outlined,
            title: "Dashboard",
          ),

          _menu(
            index: 1,
            icon: Icons.inventory_2_outlined,
            title: "Produk Saya",
          ),

          _menu(
            index: 2,
            icon: Icons.shopping_cart_outlined,
            title: "Pesanan",
          ),

          _menu(
            index: 3,
            icon: Icons.category_outlined,
            title: "Kategori",
          ),

          const Spacer(),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              "Keluar",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: onLogout,
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _menu({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final bool active = selectedIndex == index;

    return Builder(
      builder: (context) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xffEEF4FF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              icon,
              color: active
                  ? const Color(0xff2563EB)
                  : Colors.black54,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: active
                    ? const Color(0xff2563EB)
                    : Colors.black87,
                fontWeight: active
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            onTap: () => onMenuSelected(index),
          ),
        );
      },
    );
  }
}