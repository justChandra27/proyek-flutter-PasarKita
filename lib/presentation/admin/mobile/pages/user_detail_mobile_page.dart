import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';

class UserDetailMobilePage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const UserDetailMobilePage({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<UserDetailMobilePage> createState() => _UserDetailMobilePageState();
}

class _UserDetailMobilePageState extends State<UserDetailMobilePage> {
  final Databases _db = AppwriteService.databases;

  Map<String, dynamic> _userData = {};
  bool _loading = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _userData = Map<String, dynamic>.from(widget.userData);
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _loading = true);
    try {
      final doc = await _db.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _userData = Map<String, dynamic>.from(doc.data);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleActive() async {
    final currentStatus = _userData['status'] as String? ?? 'active';
    final isActive = currentStatus == 'active';
    final newStatus = isActive ? 'inactive' : 'active';
    final label = isActive ? 'menonaktifkan' : 'mengaktifkan';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text('Yakin ingin $label user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(isActive ? 'Nonaktifkan' : 'Aktifkan'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _actionLoading = true);
    try {
      await _db.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: widget.userId,
        data: {'status': newStatus},
      );
      await _loadDetail();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User berhasil di${isActive ? 'nonaktifkan' : 'aktifkan'}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _actionLoading = false);
    }
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'seller':
        return Colors.green;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'seller':
        return 'Seller';
      case 'customer':
        return 'Customer';
      default:
        return role;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
      case 'pending':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Nonaktif';
      case 'pending':
        return 'Pending';
      default:
        return status;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _value(String key) {
    return _userData[key] as String? ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    final isActive = (_userData['status'] as String? ?? 'active') == 'active';
    final role = _userData['role'] as String? ?? 'customer';
    final name = _userData['name'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      appBar: AppBar(
        title: const Text('Detail User',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileHeader(name, role),
                  const SizedBox(height: 16),
                  _buildInfoCard('Informasi User', [
                    _infoRow(Icons.person, 'Nama', _value('name')),
                    _infoRow(Icons.alternate_email, 'Username', _value('username')),
                    _infoRow(Icons.email, 'Email', _value('email')),
                    _infoRow(Icons.badge, 'Role', _roleLabel(role),
                        valueColor: _roleColor(role)),
                    _infoRow(Icons.circle, 'Status', _statusLabel(_value('status')),
                        valueColor: _statusColor(_value('status'))),
                    _infoRow(Icons.phone, 'Telepon', _value('phone')),
                    _infoRow(Icons.home, 'Alamat', _value('shippingAddress')),
                    _infoRow(Icons.location_city, 'Kota', _value('shippingCity')),
                    _infoRow(Icons.map, 'Provinsi', _value('shippingProvince')),
                    _infoRow(
                        Icons.calendar_today, 'Registrasi', _formatDate(_userData['\$createdAt'] as String?)),
                  ]),
                  if (role == 'seller') ...[
                    const SizedBox(height: 12),
                    _buildInfoCard('Informasi Toko', [
                      _infoRow(Icons.store, 'Nama Toko', _value('storeName')),
                      _infoRow(
                          Icons.storefront, 'Alamat Toko', _value('storeAddress')),
                    ]),
                  ],
                  const SizedBox(height: 20),
                  _buildActivationButton(isActive),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(String name, String role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: _roleColor(role).withValues(alpha: 0.2),
            child: Text(
              _getInitials(name),
              style: TextStyle(
                color: _roleColor(role),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _roleColor(role).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _roleLabel(role),
              style: TextStyle(
                color: _roleColor(role),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xff111827),
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? const Color(0xff111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivationButton(bool isActive) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: isActive
          ? OutlinedButton.icon(
              onPressed: _actionLoading ? null : _toggleActive,
              icon: _actionLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.block),
              label: const Text('Nonaktifkan User'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: _actionLoading ? null : _toggleActive,
              icon: _actionLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: const Text('Aktifkan User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
    );
  }
}
