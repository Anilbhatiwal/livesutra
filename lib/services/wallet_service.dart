import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/wallet_model.dart';

class WalletService {
  WalletService._();

  static final WalletService instance = WalletService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _walletCollection =>
      _firestore.collection('wallet');

  /// Create wallet if not exists
  Future<void> createWallet(String userId) async {
    final doc = _walletCollection.doc(userId);

    final snapshot = await doc.get();

    if (snapshot.exists) return;

    final wallet = WalletModel.empty(userId);

    await doc.set(wallet.toMap());
  }

  /// Live Wallet Stream
  Stream<WalletModel> getWallet(String userId) {
    return _walletCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return WalletModel.empty(userId);
      }

      return WalletModel.fromMap(snapshot.data()!);
    });
  }

  Future<void> updateCoins(
    String userId,
    int coins,
  ) async {
    await _walletCollection.doc(userId).update({
      'coins': coins,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateDiamonds(
    String userId,
    int diamonds,
  ) async {
    await _walletCollection.doc(userId).update({
      'diamonds': diamonds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateEarning(
    String userId,
    double earning,
  ) async {
    await _walletCollection.doc(userId).update({
      'totalEarning': earning,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateWithdraw(
    String userId,
    double withdraw,
  ) async {
    await _walletCollection.doc(userId).update({
      'totalWithdraw': withdraw,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}