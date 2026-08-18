class WalletTransactionModel {
  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  final int id;
  final String type;
  final String status;
  final double amount;
  final DateTime? createdAt;

  bool get isCredit => type == 'deposit' || type == 'refund';

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: _toInt(json['id']),
      type: json['type']?.toString().trim().toLowerCase() ?? '',
      status: json['status']?.toString().trim().toLowerCase() ?? '',
      amount: _toDouble(json['amount']),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
