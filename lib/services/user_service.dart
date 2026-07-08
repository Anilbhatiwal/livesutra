import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'package:flutter/material.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current User ID
  String get currentUid => _auth.currentUser!.uid;

  /// Get Current User Data
  Future<UserModel?> getCurrentUser() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection("users")
          .doc(currentUid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromMap(
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  /// Update Profile
  Future<void> updateProfile({
    required String name,
    required String bio,
    required String photoUrl,
    required String country,
    required String gender,
    required int age,
  }) async {
    await _firestore
        .collection("users")
        .doc(currentUid)
        .update({
      "name": name,
      "bio": bio,
      "photoUrl": photoUrl,
      "country": country,
      "gender": gender,
      "age": age,
    });
  }

  /// Live User Stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream() {
    return _firestore
        .collection("users")
        .doc(currentUid)
        .snapshots();
  }
}