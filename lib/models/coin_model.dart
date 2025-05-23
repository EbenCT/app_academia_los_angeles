// lib/models/coin_model.dart
class CoinModel {
  final int amount;
  final DateTime lastUpdated;

  const CoinModel({
    required this.amount,
    required this.lastUpdated,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      amount: json['amount'] ?? 0,
      lastUpdated: json['last_updated'] != null 
          ? DateTime.parse(json['last_updated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  CoinModel copyWith({
    int? amount,
    DateTime? lastUpdated,
  }) {
    return CoinModel(
      amount: amount ?? this.amount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}