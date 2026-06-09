import 'package:flutter/material.dart';

import 'dashboard_seller_mobile.dart';
import 'web_seller_dashboard.dart';

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xffF6F8FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2962FF),
          brightness: Brightness.light,
        ),
      ),
      child: width < 768
          ? const MobileSellerDashboard()
          : const WebSellerDashboard(),
    );
  }
}