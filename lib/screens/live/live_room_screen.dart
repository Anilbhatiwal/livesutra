import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../models/live_model.dart';
import '../../services/chat_service.dart';
import '../../services/live_service.dart';
import '../../services/zego_service.dart';

class LiveRoomScreen extends StatefulWidget {
  final bool isHost;
  final String liveID;
  final String hostID;
  final String hostName;
  final String hostImage;

  const LiveRoomScreen({
    super.key,
    required this.isHost,
    required this.liveID,
    required this.hostID,
    required this.hostName,
    required this.hostImage,
  });

  @override
  State<LiveRoomScreen> createState() =>
      _LiveRoomScreenState();
}

class _LiveRoomScreenState
    extends State<LiveRoomScreen> {

  final ChatService _chatService = ChatService();

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final TextEditingController
      messageController =
      TextEditingController();

  bool engineCreated = false;

  bool micOn = true;

  bool cameraOn = true;

  bool frontCamera = true;

  bool isLiving = false;

  bool isEnding = false;

  int viewerCount = 0;

  @override
  void initState() {
    super.initState();

    initRoom();
  }

  Future<void> initRoom() async {

    await ZegoService.init();

    setState(() {
      engineCreated = true;
    });

    await ZegoExpressEngine.instance.loginRoom(
      widget.liveID,
      ZegoUser(
        _auth.currentUser!.uid,
        _auth.currentUser?.displayName ??
            widget.hostName,
      ),
    );

    if (widget.isHost) {

      await startHost();

    } else {

      await startViewer();

    }
  }

  Future<void> startHost() async {

    await ZegoExpressEngine.instance
        .startPreview();

    await ZegoExpressEngine.instance
        .startPublishingStream(
      widget.liveID,
    );

    final live = LiveModel(
      liveId: widget.liveID,
      hostId: widget.hostID,
      hostName: widget.hostName,
      hostImage: widget.hostImage,
      viewers: 0,
      isLive: true,
      startedAt: DateTime.now(),
    );

    await LiveService.createLive(live);

    setState(() {
      isLiving = true;
    });
  }

  Future<void> startViewer() async {

    await ZegoExpressEngine.instance
        .startPlayingStream(
      widget.liveID,
    );

    viewerCount++;

    await LiveService.updateViewerCount(
      widget.liveID,
      viewerCount,
    );

    setState(() {});
  }

  Future<void> stopLive() async {

    if (isEnding) return;

    isEnding = true;

    if (widget.isHost) {

      await ZegoExpressEngine.instance
          .stopPublishingStream();

      await ZegoExpressEngine.instance
          .stopPreview();

      await LiveService.endLive(
        widget.liveID,
      );

    } else {

      if (viewerCount > 0) {

        viewerCount--;

        await LiveService.updateViewerCount(
          widget.liveID,
          viewerCount,
        );

      }

      await ZegoExpressEngine.instance
          .stopPlayingStream(
        widget.liveID,
      );
    }

    await ZegoExpressEngine.instance
        .logoutRoom(widget.liveID);

    await ZegoService.destroy();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> toggleMic() async {

    micOn = !micOn;

    await ZegoExpressEngine.instance
        .muteMicrophone(!micOn);

    setState(() {});
  }

  Future<void> toggleCamera() async {

    cameraOn = !cameraOn;

    await ZegoExpressEngine.instance
        .enableCamera(cameraOn);

    setState(() {});
  }

  Future<void> switchCamera() async {

    frontCamera = !frontCamera;

    await ZegoExpressEngine.instance
        .useFrontCamera(frontCamera);

    setState(() {});
  }

  Future<bool> onExit() async {

    final result = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            widget.isHost
                ? "End Live?"
                : "Leave Live?",
          ),
          content: Text(
            widget.isHost
                ? "Do you really want to end live?"
                : "Leave this live room?",
          ),
          actions: [

            TextButton(
              onPressed: (){
                Navigator.pop(context,false);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: (){
                Navigator.pop(context,true);
              },
              child: Text(
                widget.isHost
                    ? "End"
                    : "Leave",
              ),
            )

          ],
        );
      },
    );

    if(result==true){

      await stopLive();

    }

    return false;
  }
    @override
  Widget build(BuildContext context) {
    if (!engineCreated) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
  if (!didPop) {
    await onExit();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,

        body: Stack(
          children: [

            /// ===========================
            /// VIDEO AREA
            /// ===========================
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Text(
                    "ZEGO LIVE VIDEO",
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            /// ===========================
            /// TOP BAR
            /// ===========================
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  children: [

                    CircleAvatar(
                      radius: 23,
                      backgroundImage:
                          widget.hostImage.isNotEmpty
                              ? NetworkImage(widget.hostImage)
                              : null,
                      child: widget.hostImage.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),

                    const SizedBox(width: 10),

                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          widget.hostName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          "$viewerCount Watching",
                          style: const TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius:
                            BorderRadius.circular(30),
                      ),
                      child: const Text(
                        "🔴 LIVE",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    IconButton(
                      onPressed: onExit,
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
                        /// ===========================
            /// LIVE CHAT
            /// ===========================
            Positioned(
              left: 10,
              right: 10,
              bottom: 95,
              child: SizedBox(
                height: 250,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _chatService.getMessages(widget.liveID),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index];

                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
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

            /// ===========================
            /// BOTTOM BAR
            /// ===========================
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(12),
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
                      onPressed: () async {

                        if(messageController.text.trim().isEmpty){
                          return;
                        }

                        await _chatService.sendMessage(
                          roomId: widget.liveID,
                          userName: _auth.currentUser?.displayName ?? "User",
                          message: messageController.text.trim(),
                        );

                        messageController.clear();

                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.blue,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.card_giftcard,
                        color: Colors.amber,
                      ),
                    ),

                    if(widget.isHost)
                    IconButton(
                      onPressed: toggleMic,
                      icon: Icon(
                        micOn
                            ? Icons.mic
                            : Icons.mic_off,
                        color: Colors.white,
                      ),
                    ),

                    if(widget.isHost)
                    IconButton(
                      onPressed: toggleCamera,
                      icon: Icon(
                        cameraOn
                            ? Icons.videocam
                            : Icons.videocam_off,
                        color: Colors.white,
                      ),
                    ),

                    if(widget.isHost)
                    IconButton(
                      onPressed: switchCamera,
                      icon: const Icon(
                        Icons.cameraswitch,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    stopLive();
    super.dispose();
  }
}