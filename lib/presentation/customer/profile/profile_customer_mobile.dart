//lib/presentation/customer/profile/profile_customer_mobile.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../auth/login_page.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../data/models/user_model.dart';
import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';

class ProfileCustomerMobile extends StatefulWidget {
  const ProfileCustomerMobile({super.key});

  @override
  State<ProfileCustomerMobile> createState() =>
      _ProfileCustomerMobileState();
}

class _ProfileCustomerMobileState
    extends State<ProfileCustomerMobile> {
  final AuthServiceAppwrite _authService = AuthServiceAppwrite();
  models.User? _account;
  UserModel? _userModel;
  int _orderCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUser());
  }

  Future<void> _loadUser() async {
    try {
      final account = await _authService.getCurrentUser();
      final databases = AppwriteService.databases;

      UserModel? userModel;
      try {
        final result = await databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.usersCollectionId,
          queries: [Query.equal('uid', account.$id)],
        );
        if (result.documents.isNotEmpty) {
          userModel = UserModel.fromMap(
            result.documents.first.data,
            result.documents.first.$id,
          );
        }
      } catch (_) {}

      int orderCount = 0;
      try {
        final orderResult = await databases.listDocuments(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.ordersCollectionId,
          queries: [Query.equal('customerId', account.$id), Query.limit(1)],
        );
        orderCount = orderResult.total;
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _account = account;
        _userModel = userModel;
        _orderCount = orderCount;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _userModel?.name ?? _account?.name ?? 'User';
    final email = _userModel?.email ?? _account?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "PasarKita",
                  style: TextStyle(
                    color: Color(0xff2563EB),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffEAF1FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xff2563EB),
                              width: 3,
                            ),
                          ),
                          child: const CircleAvatar(
                            backgroundColor: Colors.black12,
                            child: Icon(Icons.person, size: 50),
                          ),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Tooltip(
                            message: 'Fitur akan diimplementasikan berikutnya',
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xff2563EB),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      email,
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _orderCount.toString(),
                            style: const TextStyle(
                              color: Color(0xff2563EB),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text("Orders"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Text(
                            "Account Settings",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const Spacer(),

                          Icon(Icons.settings, color: Colors.blue.shade700),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    _menuItem(
                      icon: Icons.person_outline,
                      title: "Personal Information",
                      subtitle: "Update your name, email, and phone",
                      enabled: true,
                      onTap: () => _showPersonalInfoDialog(),
                    ),

                    const Divider(height: 1),

                    _menuItem(
                      icon: Icons.location_on_outlined,
                      title: "Address Book",
                      subtitle: "Manage your primary and shipping address",
                      enabled: true,
                      onTap: () => _showAddressDialog(),
                    ),

                    const Divider(height: 1),

                    _menuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Payment Methods",
                      subtitle: "Saved cards and digital wallets",
                      enabled: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await AuthServiceAppwrite().logout();

                      if (!context.mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Logout gagal: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showPersonalInfoDialog() {
    final nameCtrl = TextEditingController(text: _userModel?.name ?? _account?.name ?? '');
    final phoneCtrl = TextEditingController(text: _userModel?.phone ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Personal Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Nomor Telepon'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await AuthServiceAppwrite().updateUserData({
                  'name': nameCtrl.text.trim(),
                  'phone': phoneCtrl.text.trim(),
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _loadUser();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil tersimpan'), backgroundColor: Colors.green),
                );
              } catch (e) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAddressDialog() {
    final addressCtrl = TextEditingController(text: _userModel?.shippingAddress ?? '');
    final cityCtrl = TextEditingController(text: _userModel?.shippingCity ?? '');
    final provinceCtrl = TextEditingController(text: _userModel?.shippingProvince ?? '');
    final postalCtrl = TextEditingController(text: _userModel?.shippingPostalCode ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Address Book'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Alamat Lengkap'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: cityCtrl,
              decoration: const InputDecoration(labelText: 'Kota'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: provinceCtrl,
              decoration: const InputDecoration(labelText: 'Provinsi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: postalCtrl,
              decoration: const InputDecoration(labelText: 'Kode Pos'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await AuthServiceAppwrite().updateUserData({
                  'shippingAddress': addressCtrl.text.trim(),
                  'shippingCity': cityCtrl.text.trim(),
                  'shippingProvince': provinceCtrl.text.trim(),
                  'shippingPostalCode': postalCtrl.text.trim(),
                });
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _loadUser();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alamat tersimpan'), backgroundColor: Colors.green),
                );
              } catch (e) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(icon, color: enabled ? Colors.black54 : Colors.black26),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled ? Colors.black : Colors.black38,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: enabled ? null : Colors.black26,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: enabled ? null : Colors.black26,
      ),
      onTap: enabled ? onTap : null,
    );
  }
}
