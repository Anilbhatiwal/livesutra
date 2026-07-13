import 'package:flutter/material.dart';

import '../../../models/chat_model.dart';
import 'level_badge.dart';
import 'vip_badge.dart';

class LiveChatItem extends StatelessWidget {
  final ChatModel chat;

  const LiveChatItem({
    super.key,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: chat.senderImage.isNotEmpty
                ? NetworkImage(chat.senderImage)
                : null,
            child: chat.senderImage.isEmpty
                ? const Icon(Icons.person, size: 18)
                : null,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const VipBadge(vipLevel: 3),

                      const LevelBadge(level: 18),

                      Expanded(
                        child: Text(
                          chat.senderName,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight:
                                FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    chat.message,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}