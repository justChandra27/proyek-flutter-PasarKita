//lib/presentation/customer/profile/profile_customer_web.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import 'package:pasarkita/core/services/auth_service_appwrite.dart';
import 'package:pasarkita/data/models/user_model.dart';
import 'package:pasarkita/core/appwrite/appwrite_config.dart';
import 'package:pasarkita/core/appwrite/appwrite_service.dart';
import 'package:pasarkita/presentation/auth/login_page.dart';

class ProfileCustomerWeb extends StatefulWidget {
  const ProfileCustomerWeb({super.key});

  @override
  State<ProfileCustomerWeb> createState() =>
      _ProfileCustomerWebState();
}

class _ProfileCustomerWebState
    extends State<ProfileCustomerWeb> {
  final AuthServiceAppwrite _authService = AuthServiceAppwrite();
  models.User? _account;
  UserModel? _userModel;
  int _orderCount = 0;
  bool _loading = true;
  bool _saving = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUser());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    super.dispose();
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
        _nameController.text = userModel?.name ?? account.name;
        _phoneController.text = userModel?.phone ?? '';
        _addressController.text = userModel?.shippingAddress ?? '';
        _cityController.text = userModel?.shippingCity ?? '';
        _provinceController.text = userModel?.shippingProvince ?? '';
        _postalCodeController.text = userModel?.shippingPostalCode ?? '';
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

  String _initials(String name) {
    if (name.isEmpty) return '?';
    return name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase();
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
      backgroundColor: const Color(0xffF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Akun Saya",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2563EB),
                    ),
                  ),
                ),

                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xff2563EB).withValues(alpha: .15),
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      color: Color(0xff2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // PROFILE CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xff2563EB).withValues(alpha: .15),
                        child: Text(
                          _initials(name),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff2563EB),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Tooltip(
                          message: 'Fitur akan diimplementasikan berikutnya',
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0xff2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Member",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _statCard(
                    _orderCount.toString(),
                    "PESANAN",
                  ),

                  const SizedBox(width: 12),

                  _statCard(
                    "0",
                    "TRANSAKSI",
                  ),

                  const SizedBox(width: 12),

                  _statCard(
                    "0",
                    "POIN",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // INFORMASI PRIBADI & ALAMAT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Informasi Pribadi",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _editableField(
                          "NAMA LENGKAP",
                          _nameController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _readOnlyField(
                          "ALAMAT EMAIL",
                          email,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _editableField(
                          "NOMOR TELEPON",
                          _phoneController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Alamat Pengiriman",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _editableField(
                    "ALAMAT LENGKAP",
                    _addressController,
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _editableField(
                          "KOTA",
                          _cityController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _editableField(
                          "PROVINSI",
                          _provinceController,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _editableField(
                          "KODE POS",
                          _postalCodeController,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Divider(),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 220,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _saving
                              ? const Color(0xff2563EB).withValues(alpha: .5)
                              : const Color(0xff2563EB),
                        ),
                        onPressed: _saving ? null : _onSave,
                        child: _saving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Simpan Perubahan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
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

  static Widget _statCard(
    String value,
    String title,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xff2563EB),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    setState(() => _saving = true);
    try {
      await _authService.updateUserData({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'shippingAddress': _addressController.text.trim(),
        'shippingCity': _cityController.text.trim(),
        'shippingProvince': _provinceController.text.trim(),
        'shippingPostalCode': _postalCodeController.text.trim(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
      _loadUser();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static Widget _editableField(
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color(0xffF8FAFC),
          ),
        ),
      ],
    );
  }

  static Widget _readOnlyField(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: Color(0xffF1F5F9),
          ),
        ),
      ],
    );
  }
}
