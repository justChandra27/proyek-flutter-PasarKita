import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'presentation/auth/login_page.dart';
import 'presentation/navigation/navigation_page.dart';
import 'presentation/product/add_product_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

      routes: {'/add-product': (context) => const AddProductPage()},
    );
  }
}
