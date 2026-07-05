import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/chat_service.dart';

class LiveRoomScreen extends StatefulWidget {
  const LiveRoomScreen({super.key});

  @override
  State<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

class _LiveRoomScreenState extends State<LiveRoomScreen> {
  final ChatService chatService = ChatService();

  final TextEditingController messageController =
      TextEditingController();

  final String roomId = "room1";

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          /// Background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade900,
            child: const Center(
              child: Icon(
                Icons.live_tv,
                size: 120,
                color: Colors.white24,
              ),
            ),
          ),

          /// Top Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [

                  const CircleAvatar(
                    radius: 22,
                    child: Icon(Icons.person),
                  ),

                  const SizedBox(width: 10),

                  const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Arjun",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        "2.3K Watching",
                        style: TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "LIVE",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// Chat List
          Positioned(
            left: 10,
            right: 10,
            bottom: 90,
            child: SizedBox(
              height: 260,

              child: StreamBuilder<QuerySnapshot>(
                stream:
                    chatService.getMessages(roomId),

                builder:
                    (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }

                  final docs =
                      snapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder:
                        (context, index) {

                      final data =
                          docs[index];
                                                return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(
                            bottom: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [

                              Text(
                                data["userName"] ?? "",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                data["message"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          /// Bottom Message Box
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(15),
              color: Colors.black54,
              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Say something...",
                        hintStyle: const TextStyle(
                          color: Colors.white54,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  IconButton(
                    onPressed: () async {

                      if (messageController.text
                          .trim()
                          .isEmpty) {
                        return;
                      }

                      await chatService.sendMessage(
                        roomId: roomId,
                        userName: "Arjun",
                        message: messageController.text
                            .trim(),
                      );

                      messageController.clear();
                    },
                    icon: const Icon(
                      Icons.send,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.card_giftcard,
                      color: Colors.amber,
                      size: 30,
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