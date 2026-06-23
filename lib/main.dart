// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/auth/login_page.dart';
import 'presentation/admin/admin_page.dart';
import 'presentation/admin/mobile/admin_mobile_shell.dart';
import 'presentation/seller/seller_page.dart';
import 'presentation/customer/customer_page.dart';
import 'core/appwrite/appwrite_test.dart';
import 'core/controllers/transaksi_controller.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_filter_provider.dart';

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
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductFilterProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PasarKita',
        home: BootstrapWidget(),
      ),
    );
  }
}

class BootstrapWidget extends StatefulWidget {
  const BootstrapWidget({super.key});

  @override
  State<BootstrapWidget> createState() => _BootstrapWidgetState();
}

class _BootstrapWidgetState extends State<BootstrapWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isLoggedIn || auth.currentUser == null) {
      return const LoginPage();
    }

    final role = auth.currentUser!['role'] as String?;
    if (role == 'admin') {
      final isMobile = MediaQuery.of(context).size.width < 768;
      return isMobile ? const AdminMobileShell() : const AdminPage();
    }
    if (role == 'seller') return const SellerPage();
    return const CustomerPage();
  }
}