import 'package:flutter/material.dart';

import 'dashboard/dashboard_customer_mobile.dart';
import 'cart/cart_customer_mobile.dart';
import 'orders/pesanan_customer_mobile.dart';
import 'profile/profile_customer_mobile.dart';
import 'notifications/notifikasi_customer_mobile.dart';

import 'widgets/bottom_nav_customer_mobile.dart';
import '../../core/services/auth_service_appwrite.dart';
import '../../core/services/notification_service_appwrite.dart';

class CustomerMobilePage
    extends StatefulWidget {
  final int initialIndex;
  const CustomerMobilePage({super.key, this.initialIndex = 0});

  @override
  State<CustomerMobilePage> createState() =>
      _CustomerMobilePageState();
}

class _CustomerMobilePageState
    extends State<CustomerMobilePage> {
  int selectedIndex = 0;
  int _unreadCount = 0;
  final NotificationServiceAppwrite _notifService =
      NotificationServiceAppwrite();
  final GlobalKey<PesananCustomerMobileState> _pesananKey = GlobalKey();

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    pages = [
      const DashboardCustomerMobile(),
      const CartCustomerMobile(),
      PesananCustomerMobile(key: _pesananKey),
      const NotifikasiCustomerMobile(),
      const ProfileCustomerMobile(),
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
      body: pages[selectedIndex],
      bottomNavigationBar:
          BottomNavCustomerMobile(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          if (index == 2) _pesananKey.currentState?.refresh();
          if (index == 3) _loadUnreadCount();
        },
        unreadNotifCount: _unreadCount,
      ),
    );
  }
}
