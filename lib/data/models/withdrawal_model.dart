class WithdrawalModel {
  final String id;
  final String sellerId;
  final int amount;
  final String bankName;
  final String bankAccount;
  final String accountName;
  final String status;
  final String adminNote;
  final String requestedAt;
  final String processedAt;
  final String processedBy;

  WithdrawalModel({
    required this.id,
    required this.sellerId,
    required this.amount,
    required this.bankName,
    required this.bankAccount,
    required this.accountName,
    this.status = 'pending',
    this.adminNote = '',
    required this.requestedAt,
    this.processedAt = '',
    this.processedBy = '',
  });

  factory WithdrawalModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return WithdrawalModel(
      id: id,
      sellerId: data['sellerId'] ?? '',
      amount: data['amount'] ?? 0,
      bankName: data['bankName'] ?? '',
      bankAccount: data['bankAccount'] ?? '',
      accountName: data['accountName'] ?? '',
      status: data['status'] ?? 'pending',
      adminNote: data['adminNote'] ?? '',
      requestedAt: data['requestedAt'] ?? '',
      processedAt: data['processed_at'] ?? '',
      processedBy: data['processed_by'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'amount': amount,
      'bankName': bankName,
      'bankAccount': bankAccount,
      'accountName': accountName,
      'status': status,
      'adminNote': adminNote,
      'requestedAt': requestedAt,
      'processed_at': processedAt,
      'processed_by': processedBy,
    };
  }
}
