import 'package:flutter/material.dart';

import 'edit_profile_page.dart';
import 'order_history_page.dart';
import '../auth/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // AVATAR
              const CircleAvatar(
                radius: 50,

                backgroundColor: Color(0xFFD4AF37),

                child: Icon(Icons.person, size: 60, color: Colors.black),
              ),

              const SizedBox(height: 20),

              // NAME
              const Text(
                "Komang Jaya",

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              // EMAIL
              const Text(
                "komang@email.com",

                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // EDIT PROFILE
              profileMenu(
                context,

                icon: Icons.edit,

                title: "Edit Profile",

                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ORDER HISTORY
              profileMenu(
                context,

                icon: Icons.history,

                title: "Riwayat Pesanan",

                onTap: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // LOGOUT
              profileMenu(
                context,
                icon: Icons.logout,
                title: "Logout",
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileMenu(
    BuildContext context, {

    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),

          borderRadius: BorderRadius.circular(18),
        ),

        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFD4AF37)),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 18),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
