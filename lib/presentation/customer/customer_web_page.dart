import 'package:flutter/material.dart';

import '../auth/login_page.dart';

import 'widgets/sidebar_customer_web.dart';
import 'dashboard/dashboard_customer_web.dart';
import 'cart/cart_customer_web.dart';
import 'orders/pesanan_customer_web.dart';
import 'profile/profile_customer_web.dart';
import 'notifications/notifikasi_customer_web.dart';
import '../../core/services/auth_service_appwrite.dart';
import '../../core/services/notification_service_appwrite.dart';

class CustomerWebPage extends StatefulWidget {
  const CustomerWebPage({super.key});

  @override
  State<CustomerWebPage> createState() => _CustomerWebPageState();
}

class _CustomerWebPageState extends State<CustomerWebPage> {
  int selectedIndex = 0;
  int _unreadCount = 0;
  final NotificationServiceAppwrite _notifService =
      NotificationServiceAppwrite();
  final GlobalKey<PesananCustomerWebState> _pesananKey = GlobalKey();

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      const DashboardCustomerWeb(),
      const CartCustomerWeb(),
      PesananCustomerWeb(key: _pesananKey),
      const NotifikasiCustomerWeb(),
      const ProfileCustomerWeb(),
    ];
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final account = await AuthServiceAppwrite().getCurrentUser();
      final count = await _notifService.getUnreadCount(account.$id);
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarCustomerWeb(
            selectedIndex: selectedIndex,
            unreadNotifCount: _unreadCount,
            onMenuSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
              if (index == 2) _pesananKey.currentState?.refresh();
              if (index == 3) _loadUnreadCount();
            },
            onLogout: () async {
              try {
                await AuthServiceAppwrite().logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
              }
            },
          ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
