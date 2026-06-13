//lib/presentation/admin/widgets/sidebar_admin_web.dart

import 'package:flutter/material.dart';

class SidebarAdminWeb extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onMenuSelected;
  final VoidCallback onLogout;

  const SidebarAdminWeb({
    super.key,
    required this.selectedIndex,
    required this.onMenuSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xffE5E7EB))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),

          const ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xff2563EB),
              child: Icon(Icons.storefront, color: Colors.white),
            ),
            title: Text(
              "PasarKita",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text("Admin Panel"),
          ),

          const SizedBox(height: 24),

          _menu(icon: Icons.dashboard_outlined, title: "Dashboard", index: 0),

          _menu(icon: Icons.people_outline, title: "Pengguna", index: 1),

          _menu(
            icon: Icons.verified_user_outlined,
            title: "Verifikasi",
            index: 2,
          ),

          _menu(icon: Icons.inventory_2_outlined, title: "Produk", index: 3),

          _menu(icon: Icons.shopping_bag_outlined, title: "Pesanan", index: 4),

          _menu(
            icon: Icons.receipt_long_outlined,
            title: "Transaksi",
            index: 5,
          ),

          _menu(icon: Icons.account_balance_outlined, title: "Penarikan", index: 6),

          _menu(icon: Icons.category_outlined, title: "Kategori", index: 7),

          _menu(icon: Icons.local_offer_outlined, title: "Promo", index: 8),

          _menu(icon: Icons.bar_chart_outlined, title: "Laporan", index: 9),

          const Spacer(),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Keluar", style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _menu({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool selected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffEEF4FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
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
        onTap: () {
          onMenuSelected(index);
        },
      ),
    );
  }
}
