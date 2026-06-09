//lib/presentation/seller/profile/profile_seller_mobile.dart

import 'package:flutter/material.dart';
import '../../auth/login_page.dart';
import '../../../core/services/auth_service_appwrite.dart';

class SellerEditProfileMobile extends StatelessWidget {
  const SellerEditProfileMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Profil Saya"),
        actions: [TextButton(onPressed: () {}, child: const Text("Simpan"))],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey.shade300,
              child: const Icon(Icons.person, size: 45),
            ),

            const SizedBox(height: 24),

            _sectionTitle("INFORMASI PRIBADI"),

            const SizedBox(height: 12),

            _card(
              children: [
                _field("Nama Lengkap", "Andi Setiawan"),

                _field("Email", "andi.setiawan@gmail.com"),

                _field("Nomor Telepon", "+62 812-3456-7890"),
              ],
            ),

            const SizedBox(height: 24),

            _sectionTitle("INFORMASI TOKO"),

            const SizedBox(height: 12),

            _card(
              children: [
                _field("Nama Toko", "Andi Furniture & Design"),

                _field(
                  "Deskripsi Toko",
                  "Spesialis furniture kayu jati minimalis",
                  maxLines: 4,
                ),

                _field("Lokasi", "Jl. Merdeka No.123, Bandung"),
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
