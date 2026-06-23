import 'package:flutter/material.dart';

class AdminMobileDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const AdminMobileDrawer({
    super.key,
    required this.selectedIndex,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xff2563EB),
                    child: Icon(Icons.storefront, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PasarKita",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Admin Panel",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _menuItem(
                    icon: Icons.dashboard_outlined,
                    title: "Dashboard",
                    index: 0,
                  ),
                  _menuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: "Pesanan",
                    index: 1,
                  ),
                  _menuItem(
                    icon: Icons.inventory_2_outlined,
                    title: "Produk",
                    index: 2,
                  ),
                  _menuItem(
                    icon: Icons.assignment_return_outlined,
                    title: "Retur",
                    index: 3,
                  ),
                  _menuItem(
                    icon: Icons.people_outline,
                    title: "User",
                    index: 4,
                  ),
                  _menuItem(
                    icon: Icons.settings_outlined,
                    title: "Pengaturan",
                    index: 5,
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Keluar",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: onLogout,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final selected = selectedIndex == index;
    return Container(
      decoration: BoxDecoration(
        color: selected ? const Color(0xffEEF4FF) : Colors.transparent,
        border: selected
            ? const Border(
                left: BorderSide(color: Color(0xff2563EB), width: 3),
              )
            : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? const Color(0xff2563EB) : Colors.black54,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? const Color(0xff2563EB) : Colors.black87,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () => onMenuSelected(index),
      ),
    );
  }
}
