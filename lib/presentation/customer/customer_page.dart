//lib/customer/customer_page.dart

import 'package:flutter/material.dart';

import 'customer_web_page.dart';
import 'customer_mobile_page.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {

    final width =
        MediaQuery.of(context).size.width;

    if (width < 768) {
      return const CustomerMobilePage();
    }

    return const CustomerWebPage();
  }
}