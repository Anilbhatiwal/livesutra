import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/chat_model.dart';
import '../../../services/chat_service.dart';
import '../../../controllers/live_room_controller.dart'; // Controller import add kiya
import 'live_chat_item.dart';

class LiveChatList extends StatefulWidget {
  final String roomId;
  final LiveRoomController controller; // Add kiya
  final Function(String) onSend; // Add kiya
  final VoidCallback onHeart; // Add kiya
  final Function(String giftId, String giftName, int diamonds) onGift; // Add kiya
  final bool isHost; // Add kiya

  const LiveChatList({
    super.key,
    required this.roomId,
    required this.controller,
    required this.onSend,
    required this.onHeart,
    required this.onGift,
    required this.isHost,
  });

  @override
  State<LiveChatList> createState() => _LiveChatListState();
}

class _LiveChatListState extends State<LiveChatList> {
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.roomId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final docs = snapshot.data!.docs;

        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>; // Direct crash se bachne ke liye safe cast

            final chat = ChatModel(
              id: data["id"] ?? "",
              senderId: data["senderId"] ?? "",
              senderName: data["senderName"] ?? "",
              senderImage: data["senderImage"] ?? "",
              message: data["message"] ?? "",
              messageType: data["messageType"] ?? "text",
              createdAt: data["createdAt"] != null 
                  ? (data["createdAt"] as Timestamp).toDate() 
                  : DateTime.now(),
            );

            return LiveChatItem(chat: chat);
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}