import 'package:cloud_firestore/cloud_firestore.dart';

class WalletModel {
  final String userId;

  final int coins;
  final int diamonds;

  final double totalEarning;
  final double totalWithdraw;

  final Timestamp? updatedAt;

  const WalletModel({
    required this.userId,
    required this.coins,
    required this.diamonds,
    required this.totalEarning,
    required this.totalWithdraw,
    this.updatedAt,
  });

  factory WalletModel.empty(String userId) {
    return WalletModel(
      userId: userId,
      coins: 0,
      diamonds: 0,
      totalEarning: 0,
      totalWithdraw: 0,
      updatedAt: Timestamp.now(),
    );
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      userId: map['userId'] ?? '',
      coins: map['coins'] ?? 0,
      diamonds: map['diamonds'] ?? 0,
      totalEarning: (map['totalEarning'] ?? 0).toDouble(),
      totalWithdraw: (map['totalWithdraw'] ?? 0).toDouble(),
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'coins': coins,
      'diamonds': diamonds,
      'totalEarning': totalEarning,
      'totalWithdraw': totalWithdraw,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  WalletModel copyWith({
    int? coins,
    int? diamonds,
    double? totalEarning,
    double? totalWithdraw,
  }) {
    return WalletModel(
      userId: userId,
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      totalEarning: totalEarning ?? this.totalEarning,
      totalWithdraw: totalWithdraw ?? this.totalWithdraw,
      updatedAt: updatedAt,
    );
  }
}