// ignore_for_file: unused_element, unused_element_parameter

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/live_room_controller.dart';
import '../../models/live_model.dart';

import 'widgets/live_video_view.dart';
import 'widgets/live_chat_list.dart';
import 'widgets/live_top_bar.dart';
import 'widgets/live_bottom_bar.dart';

class LiveRoomScreen extends StatelessWidget {
  const LiveRoomScreen({
    super.key,
    required this.live,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.isHost,
  });

  final LiveModel live;
  final String userId;
  final String userName;
  final String userImage;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LiveRoomController(
        live: live,
        userId: userId,
        userName: userName,
        userImage: userImage,
        isHost: isHost,
      )..initialize(),
      child: _LiveRoomBody(
        live: live,
        isHost: isHost,
      ),
    );
  }
}

class _LiveRoomBody extends StatelessWidget {
  final LiveModel live;
  final bool isHost;

  const _LiveRoomBody({
    super.key,
    required this.live,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LiveRoomController>(context);
    final liveData = controller.live;

    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onExit(context, controller);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              ///------------------------------------------------------------
              /// Live Video
              ///------------------------------------------------------------
              const Positioned.fill(
                child: LiveVideoView(),
              ),

              ///------------------------------------------------------------
              /// Top Bar
              ///------------------------------------------------------------
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: LiveTopBar(
                  hostName: liveData.hostName,
                  hostImage: liveData.hostImage,
                  viewerCount: controller.viewerCount,
                  onClose: () async {
                    await _onExit(context, controller);
                  },
                ),
              ),

              ///------------------------------------------------------------
              /// Chat
              ///------------------------------------------------------------
              Positioned(
                left: 10,
                right: 90,
                bottom: 90,
                top: 90,
                child: LiveChatList(
                  roomId: liveData.liveId,
                  controller: controller,
                  onSend: controller.sendMessage,
                  onHeart: () => controller.sendHeart(),
                  onGift: (giftId, giftName, diamonds) => controller.sendGift(
                    giftId: giftId,
                    giftName: giftName,
                    diamonds: diamonds,
                  ),
                  isHost: isHost,
                ),
              ),

              ///------------------------------------------------------------
              /// Viewer Count
              ///------------------------------------------------------------
              Positioned(
                top: 70,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.remove_red_eye, color: Colors.white, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        controller.viewerCount.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              ///------------------------------------------------------------
              /// Likes Counter
              ///------------------------------------------------------------
              Positioned(
                top: 120,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.pink.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.white, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        controller.likes.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              ///------------------------------------------------------------
              /// Diamonds Counter
              ///------------------------------------------------------------
              Positioned(
                top: 170,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.diamond, color: Colors.white, size: 18),
                      const SizedBox(width: 5),
                      Text(
                        controller.diamonds.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              ///------------------------------------------------------------
              /// Loading State
              ///------------------------------------------------------------
              if (controller.loading)
                _loadingWidget(),

              ///------------------------------------------------------------
              /// Bottom Controls
              ///------------------------------------------------------------
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LiveBottomBar(
                  controller: controller.messageController, 
                  onSend: () => controller.sendMessage(controller.messageController.text),
                  onHeart: () => controller.sendHeart(), 
                  // FIXED: Yahan parameters hata diye kyunki LiveBottomBar ka onGift parameter accept nahi kar raha tha.
                  onGift: () => controller.sendGift(
                    giftId: "default_gift_id",
                    giftName: "Rose",
                    diamonds: 10,
                  ),
                  isHost: isHost,
                  micOn: controller.micOn,
                  cameraOn: controller.cameraOn,
                  onMic: () => controller.toggleMute(), 
                  onCamera: () => controller.toggleCamera(),
                  onSwitchCamera: () => controller.switchCamera(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///------------------------------------------------------------
  /// Exit Confirmation
  ///------------------------------------------------------------
  Future<bool> _onExit(
    BuildContext context,
    LiveRoomController controller,
  ) async {
    try {
      await controller.leaveRoom();
      if (context.mounted) {
        Navigator.pop(context);
      }
      return true;
    } catch (e) {
      debugPrint("Exit Live Error : $e");
      if (context.mounted) {
        Navigator.pop(context);
      }
      return true;
    }
  }

  ///------------------------------------------------------------
  /// Error Widget
  ///------------------------------------------------------------
  Widget _errorWidget(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  ///------------------------------------------------------------
  /// Loading Widget
  ///------------------------------------------------------------
  Widget _loadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}