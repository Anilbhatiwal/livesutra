import 'package:flutter/material.dart';

class LiveBottomBar extends StatelessWidget {
  final TextEditingController controller;

  final VoidCallback onSend;
  final VoidCallback onHeart;
  final VoidCallback onGift;

  final bool isHost;

  final bool micOn;
  final bool cameraOn;

  final VoidCallback onMic;
  final VoidCallback onCamera;
  final VoidCallback onSwitchCamera;

  const LiveBottomBar({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onHeart,
    required this.onGift,
    required this.isHost,
    required this.micOn,
    required this.cameraOn,
    required this.onMic,
    required this.onCamera,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black54,
      child: Row(
        children: [

          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: "Say something...",
                hintStyle: const TextStyle(
                  color: Colors.white54,
                ),
                filled: true,
                fillColor: Colors.grey.shade900,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: onSend,
            icon: const Icon(
              Icons.send,
              color: Colors.blue,
            ),
          ),

          IconButton(
            onPressed: onHeart,
            icon: const Icon(
              Icons.favorite,
              color: Colors.red,
            ),
          ),

          IconButton(
            onPressed: onGift,
            icon: const Icon(
              Icons.card_giftcard,
              color: Colors.amber,
            ),
          ),

          if (isHost)
            IconButton(
              onPressed: onMic,
              icon: Icon(
                micOn
                    ? Icons.mic
                    : Icons.mic_off,
                color: Colors.white,
              ),
            ),

          if (isHost)
            IconButton(
              onPressed: onCamera,
              icon: Icon(
                cameraOn
                    ? Icons.videocam
                    : Icons.videocam_off,
                color: Colors.white,
              ),
            ),

          if (isHost)
            IconButton(
              onPressed: onSwitchCamera,
              icon: const Icon(
                Icons.cameraswitch,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}