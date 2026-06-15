//lib/customer/customer_page.dart

import 'package:flutter/material.dart';

import 'customer_web_page.dart';
import 'customer_mobile_page.dart';

class CustomerPage extends StatelessWidget {
  final int initialIndex;
  const CustomerPage({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;

    if (width < 768) {
      return CustomerMobilePage(initialIndex: initialIndex);
    }

    return CustomerWebPage(initialIndex: initialIndex);
  }
}