import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/live_model.dart';

class LiveService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  /// Create Live Room
  static Future<void> createLive(LiveModel live) async {
    await _firestore
        .collection("liveRooms")
        .doc(live.liveId)
        .set(live.toMap());
  }

  /// End Live
  static Future<void> endLive(String liveId) async {
    await _firestore
        .collection("liveRooms")
        .doc(liveId)
        .delete();
  }

  /// Update Viewer Count
  static Future<void> updateViewerCount(
      String liveId,
      int viewers,
      ) async {
    await _firestore
        .collection("liveRooms")
        .doc(liveId)
        .update({
      "viewers": viewers,
    });
  }

  /// Get All Live Rooms
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLiveRooms() {
    return _firestore
        .collection("liveRooms")
        .where("isLive", isEqualTo: true)
        .orderBy("startedAt", descending: true)
        .snapshots();
  }
}