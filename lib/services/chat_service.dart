import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat_model.dart';

class ChatService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;


  /// Send Live Chat Message

  Future<void> sendMessage({
    required String roomId,
    required ChatModel chat,
  }) async {

    await _firestore
        .collection("liveChats")
        .doc(roomId)
        .collection("messages")
        .doc(chat.id)
        .set(
          chat.toMap(),
        );
  }



  /// Realtime Chat Messages

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getMessages(
        String roomId,
      ) {

    return _firestore
        .collection("liveChats")
        .doc(roomId)
        .collection("messages")
        .orderBy(
          "createdAt",
        )
        .snapshots();
  }



  /// Delete Single Message

  Future<void> deleteMessage({
    required String roomId,
    required String messageId,
  }) async {

    await _firestore
        .collection("liveChats")
        .doc(roomId)
        .collection("messages")
        .doc(messageId)
        .delete();
  }



  /// Clear All Messages

  Future<void> clearChat(
    String roomId,
  ) async {

    final data =
        await _firestore
            .collection("liveChats")
            .doc(roomId)
            .collection("messages")
            .get();


    for (final doc in data.docs) {

      await doc.reference.delete();
    }
  }
    /// Add Like To Live

  Future<void> sendLike({
    required String liveId,
  }) async {

    await _firestore
        .collection("liveRooms")
        .doc(liveId)
        .update({

      "likes": FieldValue.increment(1),

    });
  }



  /// Update Viewer Count

  Future<void> updateViewerCount({
    required String liveId,
    required int count,
  }) async {

    await _firestore
        .collection("liveRooms")
        .doc(liveId)
        .update({

      "viewers": count,

    });
  }



  /// Increase Viewer Count

  Future<void> increaseViewer({
    required String liveId,
  }) async {

    await _firestore
        .collection("liveRooms")
        .doc(liveId)
        .update({

      "viewers": FieldValue.increment(1),

    });
  }



  /// Decrease Viewer Count

  Future<void> decreaseViewer({
    required String liveId,
  }) async {

    await _firestore
        .collection("liveRooms")
        .doc(liveId)
        .update({

      "viewers": FieldValue.increment(-1),

    });
  }



  /// Update Live Status

  Future<void> updateLiveStatus({
    required String liveId,
    required bool isLive,
  }) async {

    await _firestore
        .collection("liveRooms")
        .doc(liveId)
        .update({

      "isLive": isLive,

    });
  }
    /// Send Gift Event

  Future<void> sendGift({
    required String liveId,
    required String senderId,
    required String senderName,
    required String giftId,
    required String giftName,
    required int diamonds,
  }) async {

    await _firestore
        .collection("liveRooms")
        .doc(liveId)
        .collection("gifts")
        .add({

      "senderId": senderId,
      "senderName": senderName,

      "giftId": giftId,
      "giftName": giftName,

      "diamonds": diamonds,

      "createdAt":
          DateTime.now()
              .millisecondsSinceEpoch,

    });


    await _firestore
        .collection("liveRooms")
        .doc(liveId)
        .update({

      "diamonds":
          FieldValue.increment(
            diamonds,
          ),

    });
  }



  /// Get Gift Stream

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getGifts(
        String liveId,
      ) {

    return _firestore
        .collection("liveRooms")
        .doc(liveId)
        .collection("gifts")
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots();
  }



  /// Get Live Room Data

  Stream<DocumentSnapshot<Map<String, dynamic>>>
      getLiveRoom(
        String liveId,
      ) {

    return _firestore
        .collection("liveRooms")
        .doc(liveId)
        .snapshots();
  }
}