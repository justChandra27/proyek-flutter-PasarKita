// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/auth/login_page.dart';
import 'core/appwrite/appwrite_test.dart';
import 'core/controllers/transaksi_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppwriteTest.testConnection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransaksiController(),
        ),
        // Tambah provider lain di sini nanti
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PasarKita',
        home: LoginPage(),
      ),
    );
  }
}