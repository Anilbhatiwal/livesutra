import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  AdminService._();

  static final AdminService instance = AdminService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ======================================================
  // USERS
  // ======================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return _firestore
        .collection('users')
        .orderBy('name')
        .snapshots();
  }

  Future<void> blockUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isBlocked': true,
    });
  }

  Future<void> unblockUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isBlocked': false,
    });
  }

  Future<void> verifyUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isVerified': true,
    });
  }

  Future<void> unverifyUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'isVerified': false,
    });
  }

  Future<void> updateVipLevel(
    String uid,
    int vipLevel,
  ) async {
    await _firestore.collection('users').doc(uid).update({
      'vipLevel': vipLevel,
    });
  }

  Future<void> updateLevel(
    String uid,
    int level,
  ) async {
    await _firestore.collection('users').doc(uid).update({
      'level': level,
    });
  }

  // ======================================================
  // WALLET
  // ======================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> getPendingWalletOrders() {
    return _firestore
        .collection('wallet_orders')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> approveWalletOrder(String orderId) async {
    await _firestore.collection('wallet_orders').doc(orderId).update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectWalletOrder(String orderId) async {
    await _firestore.collection('wallet_orders').doc(orderId).update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }
}