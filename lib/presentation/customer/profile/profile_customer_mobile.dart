//lib/presentation/customer/profile/profile_customer_mobile.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;

import '../../auth/login_page.dart';
import '../../../core/services/auth_service_appwrite.dart';
import '../../../data/models/user_model.dart';
import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';
import '../returns/riwayat_retur_page.dart';

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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // HEADER
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Akun Saya",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff2563EB),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

              const SizedBox(height: 24),

              // PROFILE CARD
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xff2563EB).withValues(alpha: .15),
                          child: Text(
                            _initials(name),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2563EB),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Member",
                                style: TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 6),
                              _profileStatusBadge(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: _statCard(
                        _orderCount.toString(),
                        "PESANAN",
                      ),
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

                    _editableField(
                      "NAMA LENGKAP",
                      _nameController,
                    ),
                    const SizedBox(height: 12),

                    _readOnlyField(
                      "ALAMAT EMAIL",
                      email,
                    ),
                    const SizedBox(height: 12),

                    _editableField(
                      "NOMOR TELEPON",
                      _phoneController,
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

                    const SizedBox(height: 12),

                    _editableField(
                      "KOTA",
                      _cityController,
                    ),

                    const SizedBox(height: 12),

                    _editableField(
                      "PROVINSI",
                      _provinceController,
                    ),

                    const SizedBox(height: 12),

                    _editableField(
                      "KODE POS",
                      _postalCodeController,
                    ),

                    const SizedBox(height: 30),

                    const Divider(),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: const Icon(Icons.assignment_return_outlined, color: Colors.black54),
                  title: const Text(
                    "Riwayat Retur",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    "Lihat status pengajuan retur Anda",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RiwayatReturPage(),
                      ),
                    );
                  },
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

  Widget _profileStatusBadge() {
    final data = _userModel != null
        ? {
            'phone': _userModel!.phone,
            'shippingAddress': _userModel!.shippingAddress,
            'shippingCity': _userModel!.shippingCity,
            'shippingProvince': _userModel!.shippingProvince,
            'shippingPostalCode': _userModel!.shippingPostalCode,
          }
        : null;
    final isComplete = AuthServiceAppwrite.isCustomerProfileComplete(data);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.warning_amber_rounded,
          size: 16,
          color: isComplete ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 6),
        Text(
          isComplete ? 'Profile Lengkap' : 'Profile Belum Lengkap',
          style: TextStyle(
            fontSize: 13,
            color: isComplete ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget _statCard(
    String value,
    String title,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
