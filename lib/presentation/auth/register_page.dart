// pasarkita/lib/presentation/auth/register_page.dart

import 'package:flutter/material.dart';

// import '../../core/services/auth_service.dart';
import '../../core/services/auth_service_appwrite.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final fullNameController = TextEditingController();

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  String? selectedRole = 'customer';

  bool isLoading = false;
  bool agreeTerms = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final AuthServiceAppwrite _authService = AuthServiceAppwrite();

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (fullNameController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty ||
        selectedRole == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lengkapi semua data')));
      return;
    }

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui syarat dan ketentuan'),
        ),
      );
      return;
    }

    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak sesuai')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await _authService.register(
        name: fullNameController.text.trim(),
        username: usernameController.text.trim(),
        role: selectedRole!,
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil. Menunggu verifikasi admin.'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
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
      prefixIcon: Icon(icon, size: 18, color: const Color(0xff7B809A)),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xffD9DDE7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xff103DB8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: const Color(0xffF4F5FA),
      body: isMobile ? _buildMobileRegister() : _buildWebRegister(),
    );
  }

  Widget _buildWebRegister() {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: 1200,
          margin: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 20),
            ],
          ),
          child: SizedBox(
            height: 700,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: const BoxDecoration(
                      color: Color(0xff103DB8),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        const Text(
                          "Gabung Bersama PasarKita",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Nikmati kemudahan berbelanja kebutuhan segar langsung dari pedagang pasar tradisional.",
                          style: TextStyle(color: Colors.white70, height: 1.7),
                        ),

                        const SizedBox(height: 40),

                        _featureItem(
                          Icons.verified_user_outlined,
                          "Produk Terverifikasi",
                          "Semua pedagang telah melalui proses kurasi ketat untuk menjamin kualitas.",
                        ),

                        const SizedBox(height: 24),

                        _featureItem(
                          Icons.local_shipping_outlined,
                          "Pengiriman Cepat",
                          "Pesanan sampai di hari yang sama untuk menjaga kesegaran maksimal.",
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shopping_bag, color: Color(0xff103DB8)),
                            SizedBox(width: 8),
                            Text(
                              "PasarKita",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Buat Akun Baru",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Daftar sekarang dan mulai belanja segar Anda.",
                          style: TextStyle(color: Colors.black54),
                        ),

                        const SizedBox(height: 30),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _webField(
                                  "NAMA LENGKAP",
                                  TextField(
                                    controller: fullNameController,
                                    decoration: inputDecoration(
                                      hint: "Masukkan nama lengkap Anda",
                                      icon: Icons.person_outline,
                                    ),
                                  ),
                                ),

                                _webField(
                                  "ID LOGIN",
                                  TextField(
                                    controller: usernameController,
                                    decoration: inputDecoration(
                                      hint: "Masukkan ID Login",
                                      icon: Icons.badge_outlined,
                                    ),
                                  ),
                                ),

                                _webField(
                                  "DAFTAR SEBAGAI",
                                  DropdownButtonFormField<String>(
                                    initialValue: selectedRole,
                                    decoration: inputDecoration(
                                      hint: "",
                                      icon: Icons.groups_outlined,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'customer',
                                        child: Text('Pelanggan (Customer)'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'seller',
                                        child: Text('Penjual (Seller)'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedRole = value;
                                      });
                                    },
                                  ),
                                ),
                                _webField(
                                  "KATA SANDI",
                                  TextField(
                                    controller: passwordController,
                                    obscureText: obscurePassword,
                                    decoration: inputDecoration(
                                      hint: "Min. 6 karakter",
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
                                ),

                                _webField(
                                  "KONFIRMASI KATA SANDI",
                                  TextField(
                                    controller: confirmPasswordController,
                                    obscureText: obscureConfirmPassword,
                                    decoration: inputDecoration(
                                      hint: "Ulangi kata sandi",
                                      icon: Icons.check_circle_outline,
                                      suffix: IconButton(
                                        icon: Icon(
                                          obscureConfirmPassword
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            obscureConfirmPassword =
                                                !obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),

                                CheckboxListTile(
                                  value: agreeTerms,
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    "Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      agreeTerms = value ?? false;
                                    });
                                  },
                                ),

                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff103DB8),
                                    ),
                                    onPressed: isLoading ? null : register,
                                    child: isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : const Text(
                                            "Daftar Sekarang",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Sudah punya akun? Masuk di sini",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileRegister() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "PasarKita",
                style: TextStyle(
                  color: Color(0xff103DB8),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Buat Akun Baru",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Daftar sekarang dan mulai belanja kebutuhan Anda",
                    style: TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: fullNameController,
                    decoration: inputDecoration(
                      hint: "Nama Lengkap",
                      icon: Icons.person_outline,
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: usernameController,
                    decoration: inputDecoration(
                      hint: "Masukkan ID Login",
                      icon: Icons.badge_outlined,
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: inputDecoration(
                      hint: "Daftar Sebagai",
                      icon: Icons.groups_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'customer',
                        child: Text('Customer'),
                      ),
                      DropdownMenuItem(value: 'seller', child: Text('Seller')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: inputDecoration(
                      hint: "Password",
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

                  const SizedBox(height: 16),

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirmPassword,
                    decoration: inputDecoration(
                      hint: "Konfirmasi Password",
                      icon: Icons.check_circle_outline,
                      suffix: IconButton(
                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  CheckboxListTile(
                    value: agreeTerms,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "Saya menyetujui syarat dan ketentuan",
                      style: TextStyle(fontSize: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        agreeTerms = value ?? false;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff103DB8),
                      ),
                      onPressed: isLoading ? null : register,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Daftar Sekarang",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Sudah punya akun? Masuk"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _webField(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _featureItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
