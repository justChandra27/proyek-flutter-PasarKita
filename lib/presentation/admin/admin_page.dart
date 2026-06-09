//lib/presentation/admin/admin_page.dart

import 'package:flutter/material.dart';

import 'widgets/sidebar_admin_web.dart';

import 'dashboard/dashboard_admin_web.dart';
import 'users/form_pengguna_web.dart';

import 'verification/form_verifikasi_web.dart';
import 'products/form_produk_web.dart';
import 'orders/form_pesanan_web.dart';
import 'transactions/form_transaksi_web.dart';
import 'categories/form_kategori_web.dart';
import 'promo/form_promo_web.dart';
import 'reports/form_laporan_web.dart';
import '../auth/login_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const DashboardAdminWeb(),
    const FormPenggunaWeb(),
    const FormVerifikasiWeb(),
    const FormProdukWeb(),
    const FormPesananWeb(),
    const FormTransaksiWeb(),
    const FormKategoriWeb(),
    const FormPromoWeb(),
    const FormLaporanWeb(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarAdminWeb(
            selectedIndex: selectedIndex,
            onMenuSelected: (index) {
              setState(() {
                selectedIndex = index;
              });
            },

            onLogout: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),

          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
