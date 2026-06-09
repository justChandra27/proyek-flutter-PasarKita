import 'package:flutter/material.dart';

class SidebarCustomerWeb extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const SidebarCustomerWeb({
    super.key,
    required this.selectedIndex,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: const Color(0xffF1F5F9),
      child: Column(
        children: [
          const SizedBox(height: 30),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "PasarKita",
                style: TextStyle(
                  color: Color(0xff2563EB),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          _menu(
            index: 0,
            icon: Icons.home,
            title: "Home",
          ),

          _menu(
            index: 1,
            icon: Icons.shopping_cart_outlined,
            title: "Keranjang",
          ),

          _menu(
            index: 2,
            icon: Icons.receipt_long_outlined,
            title: "Pesanan Saya",
          ),

          _menu(
            index: 3,
            icon: Icons.person_outline,
            title: "Profile",
          ),

          const Spacer(),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: onLogout,
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _menu({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final active = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xffDBEAFE)
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
            fontWeight:
                active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => onMenuSelected(index),
      ),
    );
  }
}