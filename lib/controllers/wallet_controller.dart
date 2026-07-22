import 'dart:async';

import 'package:flutter/material.dart';

import '../models/wallet_model.dart';
import '../services/wallet_service.dart';

class WalletController extends ChangeNotifier {
  final WalletService _walletService = WalletService.instance;

  WalletModel? _wallet;

  WalletModel? get wallet => _wallet;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription<WalletModel>? _subscription;

  Future<void> initialize(String userId) async {
    _isLoading = true;
    notifyListeners();

    await _walletService.createWallet(userId);

    await _subscription?.cancel();

    _subscription = _walletService.getWallet(userId).listen((wallet) {
      _wallet = wallet;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> updateCoins(int coins) async {
    if (_wallet == null) return;

    await _walletService.updateCoins(
      _wallet!.userId,
      coins,
    );
  }

  Future<void> updateDiamonds(int diamonds) async {
    if (_wallet == null) return;

    await _walletService.updateDiamonds(
      _wallet!.userId,
      diamonds,
    );
  }

  Future<void> updateEarning(double amount) async {
    if (_wallet == null) return;

    await _walletService.updateEarning(
      _wallet!.userId,
      amount,
    );
  }

  Future<void> updateWithdraw(double amount) async {
    if (_wallet == null) return;

    await _walletService.updateWithdraw(
      _wallet!.userId,
      amount,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}