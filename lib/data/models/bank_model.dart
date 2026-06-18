class BankModel {
  final String id;
  final String name;
  final String code;
  final String accountNumber;
  final String accountName;

  BankModel({
    required this.id,
    required this.name,
    required this.code,
    required this.accountNumber,
    required this.accountName,
  });

  factory BankModel.fromMap(String id, Map<String, dynamic> data) {
    return BankModel(
      id: id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      accountName: data['accountName'] ?? '',
    );
  }
}
