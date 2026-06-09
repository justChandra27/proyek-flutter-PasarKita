import 'package:flutter/material.dart';

import '../../auth/login_page.dart';

class SellerSidebar extends StatelessWidget {
  const SellerSidebar({super.key});

  Widget menuItem({
    required IconData icon,
    required String title,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xffEAF2FF)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: selected
                ? const Color(0xff2962FF)
                : Colors.grey,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? const Color(0xff2962FF)
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 30),

          const ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xff2962FF),
              child: Icon(
                Icons.storefront,
                color: Colors.white,
              ),
            ),
            title: Text(
              "PasarKita",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text("Panel Penjual"),
          ),

          const SizedBox(height: 20),

          menuItem(
            icon: Icons.add_box_outlined,
            title: "Input Produk",
            selected: true,
          ),

          menuItem(
            icon: Icons.inventory_2_outlined,
            title: "Produk Saya",
          ),

          menuItem(
            icon: Icons.category_outlined,
            title: "Kategori",
          ),

          const Spacer(),

          // LOGOUT
          menuItem(
            icon: Icons.logout,
            title: "Keluar",
            onTap: () {
              showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text(
                      "Logout",
                    ),
                    content: const Text(
                      "Apakah Anda yakin ingin keluar dari akun penjual?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        child: const Text(
                          "Batal",
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                        child: const Text(
                          "Logout",
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}