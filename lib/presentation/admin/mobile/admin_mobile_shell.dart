import 'package:flutter/material.dart';

import '../../auth/login_page.dart';
import '../../../core/services/auth_service_appwrite.dart';

import 'widgets/admin_mobile_drawer.dart';
import 'pages/dashboard_mobile_page.dart';
import 'pages/orders_mobile_page.dart';
import 'pages/products_mobile_page.dart';
import 'pages/returns_mobile_page.dart';
import 'pages/users_mobile_page.dart';
import 'pages/settings_mobile_page.dart';

class AdminMobileShell extends StatefulWidget {
  const AdminMobileShell({super.key});

  @override
  State<AdminMobileShell> createState() => _AdminMobileShellState();
}

class _AdminMobileShellState extends State<AdminMobileShell> {
  int _selectedIndex = 0;
  final AuthServiceAppwrite _authService = AuthServiceAppwrite();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Map<String, dynamic>? _userData;
  bool _loadingUser = true;

  static const _pageTitles = [
    'Dashboard',
    'Pesanan',
    'Produk',
    'Retur',
    'User',
    'Pengaturan',
  ];

  List<Widget> get _pages => const [
        DashboardMobilePage(),
        OrdersMobilePage(),
        ProductsMobilePage(),
        ReturnsMobilePage(),
        UsersMobilePage(),
        SettingsMobilePage(),
      ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final data = await _authService.getCurrentUserData();
      if (!mounted) return;
      setState(() {
        _userData = data;
        _loadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingUser = false);
    }
  }

  Future<void> _onLogout() async {
    try {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminName = _loadingUser ? 'Admin' : (_userData?['name'] as String? ?? 'Admin');
    final roleRaw = _loadingUser ? 'admin' : (_userData?['role'] as String? ?? 'admin');
    final adminRole = roleRaw == 'admin' ? 'Admin' : roleRaw;
    final pageTitle = _pageTitles[_selectedIndex];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xffF7F8FC),
      endDrawer: AdminMobileDrawer(
        selectedIndex: _selectedIndex,
        onMenuSelected: (index) {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
        onLogout: _onLogout,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(pageTitle, adminName, adminRole),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, String name, String role) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 4, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff111827),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '$name | $role',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xff6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
