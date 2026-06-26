import 'package:flutter/material.dart';

class AdminMobileDrawer extends StatelessWidget {
  final int selectedIndex;
  final int unreadCount;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const AdminMobileDrawer({
    super.key,
    required this.selectedIndex,
    required this.unreadCount,
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
                    icon: Icons.people_outline,
                    title: "Pengguna",
                    index: 1,
                  ),
                  _menuItem(
                    icon: Icons.verified_user_outlined,
                    title: "Verifikasi",
                    index: 2,
                  ),
                  _menuItem(
                    icon: Icons.inventory_2_outlined,
                    title: "Produk",
                    index: 3,
                  ),
                  _menuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: "Pesanan",
                    index: 4,
                  ),
                  // _menuItem(
                  //   icon: Icons.assignment_return_outlined,
                  //   title: "Retur",
                  //   index: 5,
                  // ),
                  _menuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: "Penarikan",
                    index: 6,
                  ),
                  _menuItem(
                    icon: Icons.category_outlined,
                    title: "Kategori",
                    index: 7,
                  ),
                  // _menuItem(
                  //   icon: Icons.notifications_outlined,
                  //   title: "Notifikasi",
                  //   index: 8,
                  //   badgeCount: unreadCount,
                  // ),
                  // _menuItem(
                  //   icon: Icons.analytics_outlined,
                  //   title: "Analytics",
                  //   index: 9,
                  // ),
                  _menuItem(
                    icon: Icons.bar_chart_outlined,
                    title: "Laporan",
                    index: 10,
                  ),
                  // _menuItem(
                  //   icon: Icons.settings_outlined,
                  //   title: "Pengaturan",
                  //   index: 11,
                  // ),
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
    int badgeCount = 0,
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? const Color(0xff2563EB) : Colors.black87,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () => onMenuSelected(index),
      ),
    );
  }
}
