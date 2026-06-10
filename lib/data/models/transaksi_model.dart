class TransaksiModel {
  final String id;
  final String customerId;
  final String customerName;
  final String metode; // 'transfer_bank' | 'e_wallet' | 'tunai' | 'visa' | 'qris'
  final int jumlah;
  final String status; // 'berhasil' | 'pending' | 'gagal'
  final DateTime createdAt;
  final List<Map<String, dynamic>> items;

  TransaksiModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.metode,
    required this.jumlah,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory TransaksiModel.fromAppwrite(Map<String, dynamic> data) {
    return TransaksiModel(
      id: data['\$id'] ?? '',
      customerId: data['customer_id'] ?? '',
      customerName: data['customer_name'] ?? '',
      metode: data['metode'] ?? '',
      jumlah: data['jumlah'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: DateTime.tryParse(
            data['created_at'] ?? data['\$createdAt'] ?? '',
          ) ??
          DateTime.now(),
      items: List<Map<String, dynamic>>.from(
        (data['items'] ?? []).map(
          (e) => Map<String, dynamic>.from(e),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'metode': metode,
      'jumlah': jumlah,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'items': items,
    };
  }

  // Singkatan nama untuk avatar (2 huruf pertama)
  String get avatarInitials {
    final parts = customerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return customerName.substring(0, 2).toUpperCase();
  }

  // Label metode yang lebih rapi
  String get metodeLabel {
    switch (metode) {
      case 'transfer_bank':
        return 'Transfer Bank';
      case 'e_wallet':
        return 'E-Wallet';
      case 'tunai':
        return 'Tunai';
      case 'visa':
        return 'Visa Card';
      case 'qris':
        return 'QRIS';
      default:
        return metode;
    }
  }

  // Warna status
  // Gunakan bersama: statusLabel, bukan status langsung
  String get statusLabel {
    switch (status) {
      case 'berhasil':
        return 'Berhasil';
      case 'pending':
        return 'Pending';
      case 'gagal':
        return 'Gagal';
      default:
        return status;
    }
  }
}