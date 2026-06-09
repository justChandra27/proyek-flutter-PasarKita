import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'seller_web_page.dart';
import 'seller_mobile_page.dart';

class SellerPage extends StatelessWidget {
  const SellerPage({super.key});

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    // Browser desktop
    if (kIsWeb && width > 900) {
      return const SellerWebPage();
    }

    // Mobile / Tablet
    return const SellerMobilePage();
  }
}