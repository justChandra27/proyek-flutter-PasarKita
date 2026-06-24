import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

import '../../../../core/appwrite/appwrite_config.dart';
import '../../../../core/appwrite/appwrite_service.dart';

class VerifikasiMobilePage extends StatefulWidget {
  const VerifikasiMobilePage({super.key});

  @override
  State<VerifikasiMobilePage> createState() => _VerifikasiMobilePageState();
}

class _VerifikasiMobilePageState extends State<VerifikasiMobilePage> {
  final Databases _db = AppwriteService.databases;
  String _selectedFilter = 'all';

  Stream<List<Map<String, dynamic>>> getPendingUsers() async* {
    while (true) {
      final result = await _db.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        queries: [
          Query.equal('status', 'pending'),
          Query.limit(5000),
        ],
      );
      yield result.documents.map((e) => {...e.data, '\$id': e.$id}).toList();
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  Future<void> _approveUser(String uid, String name) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: uid,
        data: {'status': 'approved'},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name berhasil disetujui'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyetujui akun')),
      );
    }
  }

  Future<void> _rejectUser(String uid, String name) async {
    try {
      await _db.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: uid,
        data: {'status': 'rejected'},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name berhasil ditolak'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menolak akun')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: getPendingUsers(),
      builder: (context, snapshot) {
        final docs = snapshot.data ?? [];
        final sellerCount = docs.where((e) => e['role'] == 'seller').length;
        final customerCount = docs.where((e) => e['role'] == 'customer').length;

        return Column(
          children: [
            _buildFilterChips(docs.length, sellerCount, customerCount),
            const SizedBox(height: 12),
            Expanded(
              child: _buildUserList(snapshot, docs),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips(int total, int sellerCount, int customerCount) {
    final filters = [
      ('all', 'Semua', total, Colors.blue),
      ('seller', 'Seller', sellerCount, Colors.orange),
      ('customer', 'Customer', customerCount, Colors.green),
    ];

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filters.map((f) {
          final (key, label, count, color) = f;
          final selected = _selectedFilter == key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$label ($count)'),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = key),
              selectedColor: color.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: selected ? color : const Color(0xff374151),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(
                color: selected ? color : const Color(0xffE5E7EB),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUserList(AsyncSnapshot<List<Map<String, dynamic>>> snapshot, List<Map<String, dynamic>> docs) {
    if (snapshot.hasError) {
      return const Center(child: Text('Terjadi kesalahan'));
    }
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = docs.where((user) {
      if (_selectedFilter == 'all') return true;
      return user['role'] == _selectedFilter;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada akun pending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff111827)),
            ),
            const SizedBox(height: 8),
            Text(
              'Semua akun sudah terverifikasi.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filtered.length,
        itemBuilder: (_, i) => _buildUserCard(filtered[i]),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final uid = user['\$id'] as String;
    final name = user['name'] as String? ?? '';
    final username = user['username'] as String? ?? '';
    final role = user['role'] as String? ?? '';
    final createdAt = user['\$createdAt'] as String?;
    final date = createdAt != null
        ? DateTime.parse(createdAt).toString().substring(0, 16)
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withValues(alpha: 0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('@$username', style: const TextStyle(fontSize: 13, color: Color(0xff6B7280))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xff374151)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _confirmAndAction('Setujui akun $name?', () => _approveUser(uid, name)),
                  child: const Text('Setujui', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _confirmAndAction('Tolak akun $name?', () => _rejectUser(uid, name)),
                  child: const Text('Tolak'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndAction(String message, Future<void> Function() action) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
    if (confirm == true) action();
  }
}
