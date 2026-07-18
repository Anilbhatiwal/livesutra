import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Complete framework features ke liye material import

import '../models/chat_model.dart';
import '../models/live_model.dart';

import '../services/chat_service.dart';
import '../services/zego_service.dart';

class LiveRoomController extends ChangeNotifier {
  LiveRoomController({
    required this.live,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.isHost,
  });

  ///------------------------------------------------------------
  /// Live Information
  ///------------------------------------------------------------

  final LiveModel live;

  final String userId;
  final String userName;
  final String userImage;

  final bool isHost;

  ///------------------------------------------------------------
  /// Services
  ///------------------------------------------------------------

  final ChatService _chatService = ChatService();

  ///------------------------------------------------------------
  /// Local State & UI Controllers
  ///------------------------------------------------------------

  // FIX 1: messageController add kiya jo LiveRoomScreen ke chat input me use ho raha hai
  final TextEditingController messageController = TextEditingController();

  bool _initialized = false;
  bool _loading = false;

  bool _cameraOn = true;
  bool _micOn = true;
  bool _speakerOn = true;

  int _viewerCount = 0;
  int _likes = 0;
  int _diamonds = 0;

  final List<ChatModel> _messages = [];

  ///------------------------------------------------------------
  /// Streams
  ///------------------------------------------------------------

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _chatSubscription;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _giftSubscription;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _roomSubscription;

  ///------------------------------------------------------------
  /// Getters
  ///------------------------------------------------------------

  bool get initialized => _initialized;

  bool get loading => _loading;

  bool get cameraOn => _cameraOn;

  bool get micOn => _micOn;

  bool get speakerOn => _speakerOn;

  int get viewerCount => _viewerCount;

  int get likes => _likes;

  int get diamonds => _diamonds;

  List<ChatModel> get messages =>
      List.unmodifiable(_messages);

  String get roomId => live.liveId;

  String get streamId => live.streamId;

  bool get hostMode => isHost;

  bool get viewerMode => !isHost;

  int get totalMessages => _messages.length;

  ///------------------------------------------------------------
  /// Initialize Live Room
  ///------------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized) return;

    _loading = true;
    notifyListeners();

    try {
      await ZegoService.loginRoom(
        roomID: live.liveId,
        userID: userId,
        userName: userName,
      );

      if (isHost) {
        await _initializeHost();
      } else {
        await _initializeViewer();
      }

      _listenRoom();
      _listenChat();
      _listenGifts();

      _initialized = true;
    } catch (e) {
      debugPrint(
        "Initialize Error : $e",
      );
    }

    _loading = false;
    notifyListeners();
  }

  ///------------------------------------------------------------
  /// Host Initialization
  ///------------------------------------------------------------

  Future<void> _initializeHost() async {
    try {
      await ZegoService.enableCamera(true);

      await ZegoService.enableMicrophone(true);

      await ZegoService.startPreview();

      await ZegoService.startPublishing(
        streamID: live.streamId,
      );
    } catch (e) {
      debugPrint(
        "Host Initialize Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// Viewer Initialization
  ///------------------------------------------------------------

  Future<void> _initializeViewer() async {
    try {
      await ZegoService.enableSpeaker(true);

      await ZegoService.startPlaying(
        streamID: live.streamId,
      );

      await _chatService.increaseViewer(
        liveId: live.liveId,
      );
    } catch (e) {
      debugPrint(
        "Viewer Initialize Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// Live Room Listener
  ///------------------------------------------------------------

  void _listenRoom() {
    _roomSubscription?.cancel();

    _roomSubscription =
        _chatService
            .getLiveRoom(
              live.liveId,
            )
            .listen((event) {
      if (!event.exists) return;

      final data = event.data();

      if (data == null) return;

      _viewerCount = data["viewers"] ?? 0;

      _likes = data["likes"] ?? 0;

      _diamonds = data["diamonds"] ?? 0;

      notifyListeners();
    });
  }

  ///------------------------------------------------------------
  /// Chat Listener
  ///------------------------------------------------------------

  void _listenChat() {
    _chatSubscription?.cancel();

    _chatSubscription =
        _chatService
            .getMessages(
              live.liveId,
            )
            .listen((snapshot) {
      _messages.clear();

      for (final doc in snapshot.docs) {
        try {
          _messages.add(
            ChatModel.fromMap(
              doc.data(),
            ),
          );
        } catch (e) {
          debugPrint(
            "Chat Parse Error : $e",
          );
        }
      }

      notifyListeners();
    });
  }

  ///------------------------------------------------------------
  /// Gift Listener
  ///------------------------------------------------------------

  void _listenGifts() {
    _giftSubscription?.cancel();

    _giftSubscription =
        _chatService
            .getGifts(
              live.liveId,
            )
            .listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        return;
      }

      /// Gift Animation (V6)
    });
  }

  ///------------------------------------------------------------
  /// Send Message
  ///------------------------------------------------------------

  Future<void> sendMessage(
    String message,
  ) async {
    if (message.trim().isEmpty) return;

    final chat = ChatModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: userId,
      senderName: userName,
      senderImage: userImage,
      message: message.trim(),
      messageType: "text",
      createdAt: DateTime.now(),
    );

    try {
      // Input field ko clear karne ke liye
      messageController.clear();
      
      await _chatService.sendMessage(
        roomId: live.liveId,
        chat: chat,
      );
    } catch (e) {
      debugPrint(
        "Send Message Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// Send Like / Heart
  ///------------------------------------------------------------

  // FIX 2: sendHeart method banaya jo aapke existing sendLike logic ko execute karega
  Future<void> sendHeart() async {
    // Local UI update taaki fast response mile
    _likes++;
    notifyListeners();
    
    // Server/Firebase stream call
    await sendLike();
  }

  Future<void> sendLike() async {
    try {
      await _chatService.sendLike(
        liveId: live.liveId,
      );
    } catch (e) {
      debugPrint(
        "Send Like Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// Send Gift
  ///------------------------------------------------------------

  Future<void> sendGift({
    required String giftId,
    required String giftName,
    required int diamonds,
  }) async {
    try {
      // Local state real-time update karne ke liye
      _diamonds += diamonds;
      notifyListeners();

      await _chatService.sendGift(
        liveId: live.liveId,
        senderId: userId,
        senderName: userName,
        giftId: giftId,
        giftName: giftName,
        diamonds: diamonds,
      );
    } catch (e) {
      debugPrint(
        "Send Gift Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// Camera
  ///------------------------------------------------------------

  Future<void> toggleCamera() async {
    try {
      _cameraOn = !_cameraOn;

      await ZegoService.enableCamera(
        _cameraOn,
      );

      notifyListeners();
    } catch (e) {
      _cameraOn = !_cameraOn;

      debugPrint(
        "Camera Error : $e",
      );

      notifyListeners();
    }
  }

  ///------------------------------------------------------------
  /// Microphone / Audio Mute
  ///------------------------------------------------------------

  // FIX 3: toggleMute method add kiya jo aapke toggleMicrophone ko target karega
  Future<void> toggleMute() async {
    await toggleMicrophone();
  }

  Future<void> toggleMicrophone() async {
    try {
      _micOn = !_micOn;

      await ZegoService.enableMicrophone(
        _micOn,
      );

      notifyListeners();
    } catch (e) {
      _micOn = !_micOn;

      debugPrint(
        "Microphone Error : $e",
      );

      notifyListeners();
    }
  }

  ///------------------------------------------------------------
  /// Speaker
  ///------------------------------------------------------------

  Future<void> toggleSpeaker() async {
    try {
      _speakerOn = !_speakerOn;

      await ZegoService.enableSpeaker(
        _speakerOn,
      );

      notifyListeners();
    } catch (e) {
      _speakerOn = !_speakerOn;

      debugPrint(
        "Speaker Error : $e",
      );

      notifyListeners();
    }
  }

  ///------------------------------------------------------------
  /// Switch Camera
  ///------------------------------------------------------------

  Future<void> switchCamera() async {
    try {
      await ZegoService.switchCamera();
    } catch (e) {
      debugPrint(
        "Switch Camera Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// Host Controls
  ///------------------------------------------------------------

  Future<void> startPreview() async {
    if (!isHost) return;

    await ZegoService.startPreview();
  }

  Future<void> stopPreview() async {
    if (!isHost) return;

    await ZegoService.stopPreview();
  }

  Future<void> startPublishing() async {
    if (!isHost) return;

    await ZegoService.startPublishing(
      streamID: live.streamId,
    );
  }

  Future<void> stopPublishing() async {
    if (!isHost) return;

    await ZegoService.stopPublishing();
  }

  ///------------------------------------------------------------
  /// Viewer Controls
  ///------------------------------------------------------------

  Future<void> startPlaying() async {
    if (isHost) return;

    await ZegoService.startPlaying(
      streamID: live.streamId,
    );
  }

  Future<void> stopPlaying() async {
    if (isHost) return;

    await ZegoService.stopPlaying(
      streamID: live.streamId,
    );
  }

  ///------------------------------------------------------------
  /// Leave Live Room
  ///------------------------------------------------------------

  Future<void> leaveRoom() async {
    try {
      if (isHost) {
        await endLive();
      } else {
        await stopPlaying();

        await _chatService.decreaseViewer(
          liveId: live.liveId,
        );

        await ZegoService.logoutRoom(
          live.liveId,
        );
      }
    } catch (e) {
      debugPrint(
        "Leave Room Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// End Live
  ///------------------------------------------------------------

  Future<void> endLive() async {
    if (!isHost) return;

    try {
      await stopPreview();

      await stopPublishing();

      await _chatService.updateLiveStatus(
        liveId: live.liveId,
        isLive: false,
      );

      await _chatService.updateViewerCount(
        liveId: live.liveId,
        count: 0,
      );

      await _chatService.clearChat(
        live.liveId,
      );

      await ZegoService.logoutRoom(
        live.liveId,
      );
    } catch (e) {
      debugPrint(
        "End Live Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// Refresh Room
  ///------------------------------------------------------------

  Future<void> refreshRoom() async {
    _viewerCount = live.viewers;
    _likes = live.likes;
    _diamonds = live.diamonds;

    notifyListeners();
  }

  ///------------------------------------------------------------
  /// Reset Controller
  ///------------------------------------------------------------

  void reset() {
    _messages.clear();

    _viewerCount = 0;
    _likes = 0;
    _diamonds = 0;

    _cameraOn = true;
    _micOn = true;
    _speakerOn = true;

    _initialized = false;
    _loading = false;

    messageController.clear();

    notifyListeners();
  }

  ///------------------------------------------------------------
  /// Cancel Streams
  ///------------------------------------------------------------

  Future<void> _cancelSubscriptions() async {
    await _chatSubscription?.cancel();
    await _giftSubscription?.cancel();
    await _roomSubscription?.cancel();

    _chatSubscription = null;
    _giftSubscription = null;
    _roomSubscription = null;
  }

  ///------------------------------------------------------------
  /// Reconnect
  ///------------------------------------------------------------

  Future<void> reconnect() async {
    try {
      await leaveRoom();

      await Future.delayed(
        const Duration(seconds: 1),
      );

      await initialize();
    } catch (e) {
      debugPrint(
        "Reconnect Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// Close Controller
  ///------------------------------------------------------------

  Future<void> close() async {
    try {
      await leaveRoom();

      await _cancelSubscriptions();

      reset();
    } catch (e) {
      debugPrint(
        "Close Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// Dispose
  ///------------------------------------------------------------

  @override
  void dispose() {
    // FIX 4: messageController ko safely dispose kiya memory leaks rokne ke liye
    messageController.dispose();
    _cancelSubscriptions();
    _messages.clear();
    super.dispose();
  }
}