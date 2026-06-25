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

  bool _isEditing = false;
  bool _saving = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
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
    setState(() {
      _loading = false;
      _nameController.text = _userModel?.name ?? _accountName;
      _phoneController.text = _userModel?.phone ?? '';
      _storeNameController.text = _userModel?.storeName ?? '';
      _storeAddressController.text = _userModel?.storeAddress ?? '';
      _cityController.text = _userModel?.city ?? '';
      _provinceController.text = _userModel?.province ?? '';
    });
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _nameController.text = _userModel?.name ?? _accountName;
        _phoneController.text = _userModel?.phone ?? '';
        _storeNameController.text = _userModel?.storeName ?? '';
        _storeAddressController.text = _userModel?.storeAddress ?? '';
        _cityController.text = _userModel?.city ?? '';
        _provinceController.text = _userModel?.province ?? '';
      }
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nameController.text = _userModel?.name ?? _accountName;
      _phoneController.text = _userModel?.phone ?? '';
      _storeNameController.text = _userModel?.storeName ?? '';
      _storeAddressController.text = _userModel?.storeAddress ?? '';
      _cityController.text = _userModel?.city ?? '';
      _provinceController.text = _userModel?.province ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap wajib diisi')),
      );
      return;
    }
    if (_storeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama toko wajib diisi')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _authService.updateUserData({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'storeName': _storeNameController.text.trim(),
        'storeAddress': _storeAddressController.text.trim(),
        'city': _cityController.text.trim(),
        'province': _provinceController.text.trim(),
      });
      if (!mounted) return;
      await _loadUser();
      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
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

    final email = _userModel?.email ?? _accountEmail;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        title: const Text("Profil Saya"),
        actions: [
          if (_isEditing)
            Row(
              children: [
                TextButton(
                  onPressed: _saving ? null : _cancelEdit,
                  child: const Text("Batal"),
                ),
                TextButton(
                  onPressed: _saving ? null : _saveProfile,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Simpan"),
                ),
              ],
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

            const SizedBox(height: 16),

            _profileStatusBadge(),

            const SizedBox(height: 24),

            _sectionTitle("INFORMASI PRIBADI"),

            const SizedBox(height: 12),

            _card(
              children: [
                _field("Nama Lengkap", _nameController),
                _field("Email", TextEditingController(text: email), enabled: false),
                _field("Nomor HP", _phoneController),
              ],
            ),

            const SizedBox(height: 24),

            _sectionTitle("INFORMASI TOKO"),

            const SizedBox(height: 12),

            _card(
              children: [
                _field("Nama Toko", _storeNameController),
                _field("Alamat Toko", _storeAddressController),
                _field("Kota", _cityController),
                _field("Provinsi", _provinceController),
              ],
            ),

            if (!_isEditing) ...[
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    "Edit Profil",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1D4ED8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _toggleEdit,
                ),
              ),
            ],

            const SizedBox(height: 16),

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

  Widget _profileStatusBadge() {
    final data = _userModel != null
        ? {
            'phone': _userModel!.phone,
            'storeName': _userModel!.storeName,
            'storeAddress': _userModel!.storeAddress,
          }
        : null;
    final isComplete = AuthServiceAppwrite.isSellerProfileComplete(data);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
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

  Widget _field(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),

          const SizedBox(height: 8),

          TextField(
            controller: controller,
            readOnly: !enabled || (!_isEditing && enabled),
            decoration: InputDecoration(
              filled: true,
              fillColor: (!enabled || (!_isEditing && enabled))
                  ? const Color(0xffF5F6FA)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isEditing && enabled
                      ? const Color(0xff1D4ED8).withValues(alpha: .3)
                      : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xff1D4ED8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
