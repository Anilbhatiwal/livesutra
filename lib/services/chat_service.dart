import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String roomId,
    required String userName,
    required String message,
  }) async {
    await _firestore
        .collection("liveChats")
        .doc(roomId)
        .collection("messages")
        .add({
      "userName": userName,
      "message": message,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages(String roomId) {
    return _firestore
        .collection("liveChats")
        .doc(roomId)
        .collection("messages")
        .orderBy("createdAt")
        .snapshots();
  }
}