//lib/presentation/seller/profile/form_profil_seller_web.dart

import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../core/services/auth_service_appwrite.dart';
import '../../../data/models/user_model.dart';
import '../../../core/appwrite/appwrite_config.dart';
import '../../../core/appwrite/appwrite_service.dart';

class FormProfilSellerWeb extends StatefulWidget {
  const FormProfilSellerWeb({super.key});

  @override
  State<FormProfilSellerWeb> createState() => _FormProfilSellerWebState();
}

class _FormProfilSellerWebState extends State<FormProfilSellerWeb> {
  final _authService = AuthServiceAppwrite();
  UserModel? _userModel;
  String _accountName = '';
  String _accountEmail = '';
  bool _loading = true;

  final _nameController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  bool _isEditing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      _storeNameController.text = _userModel?.storeName ?? '';
      _storeAddressController.text = _userModel?.storeAddress ?? '';
      _cityController.text = _userModel?.city ?? '';
      _provinceController.text = _userModel?.province ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_userModel == null) return;
    setState(() => _saving = true);
    try {
      final databases = AppwriteService.databases;
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: _userModel!.documentId,
        data: {
          'name': _nameController.text,
          'storeName': _storeNameController.text,
          'storeAddress': _storeAddressController.text,
          'city': _cityController.text,
          'province': _provinceController.text,
        },
      );
      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
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

    final name = _userModel?.name ?? _accountName;
    final email = _userModel?.email ?? _accountEmail;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        hintText: "Cari...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _userModel?.storeName ?? 'Seller',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xff2563EB),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // TITLE
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Profil Saya",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Kelola informasi profil dan toko Anda.",
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isEditing)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1D4ED8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      "Edit Profil",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                if (_isEditing)
                  Row(
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nameController.text = _userModel?.name ?? _accountName;
                            _storeNameController.text = _userModel?.storeName ?? '';
                            _storeAddressController.text = _userModel?.storeAddress ?? '';
                            _cityController.text = _userModel?.city ?? '';
                            _provinceController.text = _userModel?.province ?? '';
                          });
                        },
                        child: const Text("Batal"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1D4ED8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _saving ? null : _saveProfile,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _section("INFORMASI PRIBADI", [
                            _field("Nama Lengkap", _nameController, _isEditing),
                            _field("Email", TextEditingController(text: email), false),
                          ]),
                          const SizedBox(height: 20),
                          _section("INFORMASI TOKO", [
                            _field("Nama Toko", _storeNameController, _isEditing),
                            _field("Alamat Toko", _storeAddressController, _isEditing),
                            _field("Kota", _cityController, _isEditing),
                            _field("Provinsi", _provinceController, _isEditing),
                          ]),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  SizedBox(
                    width: 250,
                    child: _tipsCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> fields) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(children: fields),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: !enabled,
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? Colors.white : const Color(0xffF5F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: enabled ? const Color(0xff1D4ED8).withValues(alpha: .3) : Colors.grey.shade300,
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

  Widget _tipsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1D4ED8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tips Profil",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Lengkapi profil toko Anda dengan informasi yang akurat agar pembeli lebih percaya dan mudah menemukan produk Anda.",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Pastikan nama toko, alamat, kota, dan provinsi terisi dengan benar.",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
