//lib/presentation/seller/profile/profile_seller_mobile.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../auth/login_page.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../data/models/user_model.dart';
import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';

class SellerEditProfileMobile extends StatefulWidget {
  const SellerEditProfileMobile({super.key});

  @override
  State<SellerEditProfileMobile> createState() =>
      _SellerEditProfileMobileState();
}

class _SellerEditProfileMobileState extends State<SellerEditProfileMobile> {
  final _authService = AuthServiceAppwrite();
  UserModel? _userModel;
  String _accountName = '';
  String _accountEmail = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final account = await _authService.getCurrentUser();
      _accountName = account.name;
      _accountEmail = account.email;

      final databases = AppwriteService.databases;
      final result = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [Query.equal('uid', account.$id)],
      );
      if (result.documents.isNotEmpty) {
        _userModel = UserModel.fromMap(
          result.documents.first.data,
          result.documents.first.$id,
        );
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _userModel?.name ?? _accountName;
    final email = _userModel?.email ?? _accountEmail;
    final storeName = _userModel?.storeName ?? '';
    final location = [
      if (_userModel?.city != null && _userModel!.city.isNotEmpty)
        _userModel!.city,
      if (_userModel?.province != null && _userModel!.province.isNotEmpty)
        _userModel!.province,
    ].join(', ');

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Profil Saya"),
        actions: [
          Tooltip(
            message: 'Fitur akan diimplementasikan berikutnya',
            child: TextButton(onPressed: null, child: const Text("Simpan")),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xff2563EB),
              child: Text(
                _accountName.isNotEmpty ? _accountName[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle("INFORMASI PRIBADI"),

            const SizedBox(height: 12),

            _card(
              children: [
                _field("Nama Lengkap", name),
                _field("Email", email),
                _field("Nomor Telepon", "Belum diisi"),
              ],
            ),

            const SizedBox(height: 24),

            _sectionTitle("INFORMASI TOKO"),

            const SizedBox(height: 12),

            _card(
              children: [
                _field("Nama Toko", storeName.isNotEmpty ? storeName : "Belum diisi"),
                _field(
                  "Deskripsi Toko",
                  "Belum diisi",
                  maxLines: 4,
                ),
                _field("Lokasi", location.isNotEmpty ? location : "Belum diisi"),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
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
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Logout gagal: $e')));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _field(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),

          const SizedBox(height: 8),

          TextField(
            maxLines: maxLines,
            readOnly: true,
            controller: TextEditingController(text: value),
            decoration: const InputDecoration(
              filled: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
