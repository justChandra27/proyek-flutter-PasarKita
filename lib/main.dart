import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'presentation/home/widgets/home_page.dart';
import 'presentation/navigation/navigation_page.dart';
import 'presentation/auth/login_page.dart';

void main() {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'PasarKita',

      theme: AppTheme.darkTheme,

    home: const LoginPage(),
    );
  }
}