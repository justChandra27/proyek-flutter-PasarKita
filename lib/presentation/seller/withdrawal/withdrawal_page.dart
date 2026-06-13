import 'package:flutter/material.dart';

import '../../../core/services/auth_service_appwrite.dart';
import '../../../core/services/balance_service_appwrite.dart';
import '../../../core/services/withdrawal_service_appwrite.dart';
import '../../../data/models/seller_balance_model.dart';
import '../../../data/models/withdrawal_model.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final WithdrawalServiceAppwrite _withdrawalService = WithdrawalServiceAppwrite();
  final BalanceServiceAppwrite _balanceService = BalanceServiceAppwrite();

  final _formKey = GlobalKey<FormState>();
  final _bankNameCtrl = TextEditingController();
  final _bankAccountCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  SellerBalanceModel? _balance;
  List<WithdrawalModel> _history = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _bankAccountCtrl.dispose();
    _accountNameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final account = await AuthServiceAppwrite().getCurrentUser();
      final sid = account.$id;
      final bal = await _balanceService.getBalance(sid);
      final history = await _withdrawalService.getHistory(sid);
      if (mounted) {
        setState(() {
          _balance = bal;
          _history = history;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final account = await AuthServiceAppwrite().getCurrentUser();
      await _withdrawalService.requestWithdrawal(
        sellerId: account.$id,
        amount: int.parse(_amountCtrl.text),
        bankName: _bankNameCtrl.text.trim(),
        bankAccount: _bankAccountCtrl.text.trim(),
        accountName: _accountNameCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengajuan penarikan berhasil dikirim')),
        );
        _bankNameCtrl.clear();
        _bankAccountCtrl.clear();
        _accountNameCtrl.clear();
        _amountCtrl.clear();
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = _balance?.balance ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Penarikan Saldo')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saldo card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet,
                              color: Colors.green, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Saldo Tersedia',
                                  style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                _formatPrice(available),
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Ajukan Penarikan',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _bankNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nama Bank',
                                hintText: 'Contoh: BCA, Mandiri',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Masukkan nama bank'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _bankAccountCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nomor Rekening',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Masukkan nomor rekening'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _accountNameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Nama Pemilik Rekening',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Masukkan nama pemilik rekening'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _amountCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Jumlah Penarikan',
                                prefixText: 'Rp ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Masukkan jumlah penarikan';
                                }
                                final amount = int.tryParse(v);
                                if (amount == null || amount <= 0) {
                                  return 'Jumlah harus lebih dari 0';
                                }
                                if (amount > available) {
                                  return 'Saldo tidak mencukupi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    (_submitting || available <= 0) ? null : _submit,
                                child: _submitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Text('Ajukan Penarikan'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // History
                  const Text('Riwayat Penarikan',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_history.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                            child: Text('Belum ada riwayat penarikan')),
                      ),
                    )
                  else
                    ...List.generate(_history.length, (i) {
                      final item = _history[i];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            _statusIcon(item.status),
                            color: _statusColor(item.status),
                          ),
                          title: Text(_formatPrice(item.amount)),
                          subtitle: Text(
                            '${item.bankName} - ${item.bankAccount}\n${_statusLabel(item.status)}',
                          ),
                          trailing: Text(
                            item.status == 'pending'
                                ? item.requestedAt.substring(0, 10)
                                : item.processedAt.substring(0, 10),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
