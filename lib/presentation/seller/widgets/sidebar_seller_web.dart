//lib/presentation/seller/widgets/sidebar_seller_web.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';

class SidebarSellerWeb extends StatefulWidget {
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
  State<SidebarSellerWeb> createState() => _SidebarSellerWebState();
}

class _SidebarSellerWebState extends State<SidebarSellerWeb> {
  String _sellerName = 'Seller';
  String _initial = 'S';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final auth = AuthServiceAppwrite();
      final account = await auth.getCurrentUser();
      final name = account.name;
      final databases = AppwriteService.databases;
      final result = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('uid', account.$id)],
      );
      if (result.documents.isNotEmpty) {
        final data = result.documents.first.data;
        final displayName = (data['storeName'] as String?)?.isNotEmpty == true
            ? data['storeName'] as String
            : name;
        if (!mounted) return;
        setState(() {
          _sellerName = displayName;
          _initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
        });
      } else {
        if (!mounted) return;
        setState(() {
          _sellerName = name;
          _initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
        });
      }
    } catch (_) {}
  }

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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xff2563EB),
                  child: Text(
                    _initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sellerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
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

          _menu(
            index: 4,
            icon: Icons.person_outline,
            title: "Profil Saya",
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
            onTap: widget.onLogout,
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
    final bool active = widget.selectedIndex == index;

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
            onTap: () => widget.onMenuSelected(index),
          ),
        );
      },
    );
  }
}

