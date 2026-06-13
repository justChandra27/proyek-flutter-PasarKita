//pasarkita/lib/presentation/auth/login_page.dart

import 'package:flutter/material.dart';

import '../../core/services/auth_service_appwrite.dart';

import '../admin/admin_page.dart';
import '../seller/seller_page.dart';
import '../customer/customer_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthServiceAppwrite _authService = AuthServiceAppwrite();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkExistingSession();
    });
  }

  Future<void> _checkExistingSession() async {
    try {
      final hasSession = await _authService.hasActiveSession();
      if (hasSession && mounted) {
        final userData = await _authService.getCurrentUserData();
        if (userData != null && mounted) {
          _redirectBasedOnRole(userData['role'] as String?);
        }
      }
    } catch (_) {}
  }

  void _redirectBasedOnRole(String? role) {
    if (!mounted) return;
    Widget page;
    if (role == 'admin') {
      page = const AdminPage();
    } else if (role == 'seller') {
      page = const SellerPage();
    } else {
      page = const CustomerPage();
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID dan Password wajib diisi')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final userData = await _authService.login(
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      final role = userData['role'];

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminPage()),
        );
      } else if (role == 'seller') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerPage()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      final errorMsg = e.toString();
      if (errorMsg.contains('session is active')) {
        setState(() => isLoading = false);
        try {
          final userData = await _authService.getCurrentUserData();
          if (userData != null && mounted) {
            _redirectBasedOnRole(userData['role'] as String?);
            return;
          }
        } catch (_) {}
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg.replaceFirst('Exception: ', ''))),
      );
    }
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xffF5F7FD),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xffD9DDE7)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF4F5FA),
      body: width < 900 ? _buildMobileLogin() : _buildWebLogin(),
    );
  }

  Widget _buildWebLogin() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  color: const Color(0xffF4F5FA),
                  child: Stack(
                    children: [
                      const Positioned(
                        top: 20,
                        left: 20,
                        child: Text(
                          "PasarKita",
                          style: TextStyle(
                            color: Color(0xff103DB8),
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                      ),

                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              "PasarKita",
                              style: TextStyle(
                                color: Color(0xff103DB8),
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Belanja hemat hanya di PasarKita",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 5,
                child: Center(
                  child: Container(
                    width: 420,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .08),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selamat Datang Kembali",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Silakan masukkan detail akun Anda untuk melanjutkan belanja.",
                          style: TextStyle(color: Colors.black54),
                        ),

                        const SizedBox(height: 28),

                        const Text(
                          "ID",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextField(
                          controller: usernameController,
                          decoration: inputDecoration(
                            hint: "Masukkan ID Anda",
                            icon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          "KATA SANDI",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: const Text(
                              "Lupa Kata Sandi?",
                              style: TextStyle(
                                color: Color(0xff103DB8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: inputDecoration(
                            hint: "Masukkan Password",
                            icon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff103DB8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: isLoading ? null : login,
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Masuk Sekarang",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Belum punya akun? ",
                                style: TextStyle(color: Colors.black54),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Daftar di sini",
                                  style: TextStyle(
                                    color: Color(0xff103DB8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xffD9DDE7))),
          ),
          child: const Row(
            children: [
              Text(
                "© 2024 PasarKita. Professional Freshness for everyone.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),

              Spacer(),

              Text("Kebijakan Privasi", style: TextStyle(fontSize: 12)),

              SizedBox(width: 24),

              Text("Syarat & Ketentuan", style: TextStyle(fontSize: 12)),

              SizedBox(width: 24),

              Text("Pusat Bantuan", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLogin() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xff103DB8),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: .25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 48,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "PasarKita",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xff103DB8),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Belanja hemat hanya di PasarKita",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 15),
            ),

            const SizedBox(height: 40),

            _buildMobileCard(),

            const SizedBox(height: 30),

            const Text(
              "© 2024 PasarKita",
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Selamat Datang Kembali",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 8),

          const Center(
            child: Text(
              "Masuk untuk melanjutkan",
              style: TextStyle(color: Colors.black54),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "ID",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: usernameController,
            decoration: inputDecoration(
              hint: "Masukkan ID Anda",
              icon: Icons.person_outline,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "KATA SANDI",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: inputDecoration(
              hint: "Masukkan Password",
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Lupa Kata Sandi?",
                style: TextStyle(color: Color(0xff103DB8)),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff103DB8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: isLoading ? null : login,
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Masuk Sekarang",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Belum punya akun? ",
                style: TextStyle(color: Colors.black54),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Daftar",
                  style: TextStyle(
                    color: Color(0xff103DB8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
