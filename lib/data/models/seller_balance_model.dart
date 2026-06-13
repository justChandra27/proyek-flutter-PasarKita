class SellerBalanceModel {
  final String id;
  final String sellerId;
  final int balance;
  final int totalEarned;
  final int totalWithdrawn;

  SellerBalanceModel({
    required this.id,
    required this.sellerId,
    required this.balance,
    required this.totalEarned,
    required this.totalWithdrawn,
  });

  factory SellerBalanceModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    return SellerBalanceModel(
      id: id,
      sellerId: data['sellerId'] ?? '',
      balance: data['balance'] ?? 0,
      totalEarned: data['totalEarned'] ?? 0,
      totalWithdrawn: data['totalWithdrawn'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'balance': balance,
      'totalEarned': totalEarned,
      'totalWithdrawn': totalWithdrawn,
    };
  }
}
