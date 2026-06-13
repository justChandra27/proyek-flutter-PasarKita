import 'package:flutter/material.dart';

import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/withdrawal_service_appwrite.dart';
import '../../../data/models/withdrawal_model.dart';

class FormWithdrawalAdmin extends StatefulWidget {
  const FormWithdrawalAdmin({super.key});

  @override
  State<FormWithdrawalAdmin> createState() => _FormWithdrawalAdminState();
}

class _FormWithdrawalAdminState extends State<FormWithdrawalAdmin> {
  final WithdrawalServiceAppwrite _withdrawalService = WithdrawalServiceAppwrite();
  List<WithdrawalModel> _pending = [];
  bool _isLoading = true;
  String _adminId = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final account = await AuthServiceAppwrite().getCurrentUser();
      final pending = await _withdrawalService.getPendingWithdrawals();
      if (mounted) {
        setState(() {
          _adminId = account.$id;
          _pending = pending;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  String _formatPrice(int price) {
    final p = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < p.length; i++) {
      if (i > 0 && (p.length - i) % 3 == 0) buffer.write('.');
      buffer.write(p[i]);
    }
    return 'Rp $buffer';
  }

  Future<void> _approve(WithdrawalModel w) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Setujui Penarikan'),
        content: Text(
          'Setujui penarikan ${_formatPrice(w.amount)} dari seller ${w.sellerId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _withdrawalService.approveWithdrawal(w.id, _adminId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penarikan disetujui'),
            backgroundColor: Colors.green,
          ),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _reject(WithdrawalModel w) async {
    final reasonCtrl = TextEditingController();
    final rejected = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Penarikan'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: 'Alasan penolakan',
            hintText: 'Wajib diisi',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (reasonCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan wajib diisi')),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (rejected != true) return;

    try {
      await _withdrawalService.rejectWithdrawal(
        withdrawalId: w.id,
        adminId: _adminId,
        note: reasonCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Penarikan ditolak'),
            backgroundColor: Colors.orange,
          ),
        );
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
    reasonCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Penarikan',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          width: 380,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Cari seller...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) {},
          ),
        ),
        const SizedBox(width: 20),
        const CircleAvatar(
          radius: 22,
          backgroundColor: Color(0xff2962FF),
          child: Text('A', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak ada pengajuan penarikan',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
        columns: const [
          DataColumn(label: Text('Seller ID')),
          DataColumn(label: Text('Bank')),
          DataColumn(label: Text('No. Rekening')),
          DataColumn(label: Text('Pemilik')),
          DataColumn(label: Text('Jumlah')),
          DataColumn(label: Text('Tanggal')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: _pending.map((w) {
          return DataRow(cells: [
            DataCell(Text(w.sellerId.length > 12
                ? '${w.sellerId.substring(0, 12)}...'
                : w.sellerId)),
            DataCell(Text(w.bankName)),
            DataCell(Text(w.bankAccount)),
            DataCell(Text(w.accountName)),
            DataCell(Text(_formatPrice(w.amount),
                style: const TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(w.requestedAt.substring(0, 10))),
            DataCell(Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => _approve(w),
                  child: const Text('Setujui'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () => _reject(w),
                  child: const Text('Tolak'),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }
}
