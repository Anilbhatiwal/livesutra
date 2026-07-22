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

  final TextEditingController messageController = TextEditingController();

  bool _initialized = false;
  bool _loading = false;

  bool _cameraOn = true;
  bool _micOn = true;
  bool _speakerOn = true;

  bool _connected = false;
  bool _reconnecting = false;

  bool _isDisposed = false;

  String _connectionText = "Connecting...";

  int _networkQuality = 0;

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

  bool get connected => _connected;

  bool get reconnecting => _reconnecting;

  String get connectionText => _connectionText;

  int get networkQuality => _networkQuality;

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
  /// Safe Notify Listeners (BADLAV 1: Crashing se bachane ke liye)
  ///------------------------------------------------------------
  void safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  ///------------------------------------------------------------
  /// Initialize Live Room
  ///------------------------------------------------------------

  Future<void> initialize() async {
    if (_initialized) return;

    _loading = true;
    safeNotifyListeners();

    try {
      await ZegoService.loginRoom(
        roomID: live.liveId,
        userID: userId,
        userName: userName,
      );

      // BADLAV 2: Zego callbacks ke andar notifyListeners को safeNotifyListeners se badla
      ZegoService.registerCallbacks(
        onRoomConnected: () {
          _connected = true;
          _reconnecting = false;
          _connectionText = "Connected";
          safeNotifyListeners();
        },

        onRoomDisconnected: () {
          _connected = false;
          _connectionText = "Disconnected";
          safeNotifyListeners();
        },

        onPublishQuality: (quality) {
          _networkQuality = quality.index;
          safeNotifyListeners();
        },

        onPlayQuality: (quality) {
          _networkQuality = quality.index;
          safeNotifyListeners();
        },
      );

      if (isHost) {
        await _initializeHost();
      } else {
        await _initializeViewer();
      }

      _listenRoom();
      _listenChat();
      _listenGifts();

      _connected = true;
      _reconnecting = false;
      _connectionText = "Connected";

      _initialized = true;
    } catch (e) {
      debugPrint(
        "Initialize Error : $e",
      );
    }

    _loading = false;
    safeNotifyListeners();
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

      safeNotifyListeners();
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

      safeNotifyListeners();
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

  Future<void> sendHeart() async {
    _likes++;
    safeNotifyListeners();
    
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
      _diamonds += diamonds;
      safeNotifyListeners();

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

      safeNotifyListeners();
    } catch (e) {
      _cameraOn = !_cameraOn;

      debugPrint(
        "Camera Error : $e",
      );

      safeNotifyListeners();
    }
  }

  ///------------------------------------------------------------
  /// Microphone / Audio Mute
  ///------------------------------------------------------------

  Future<void> toggleMute() async {
    await toggleMicrophone();
  }

  Future<void> toggleMicrophone() async {
    try {
      _micOn = !_micOn;

      await ZegoService.enableMicrophone(
        _micOn,
      );

      safeNotifyListeners();
    } catch (e) {
      _micOn = !_micOn;

      debugPrint(
        "Microphone Error : $e",
      );

      safeNotifyListeners();
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

      safeNotifyListeners();
    } catch (e) {
      _speakerOn = !_speakerOn;

      debugPrint(
        "Speaker Error : $e",
      );

      safeNotifyListeners();
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

    safeNotifyListeners();
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

    safeNotifyListeners();
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
    if (_reconnecting) return;

    _reconnecting = true;
    _connectionText = "Reconnecting...";
    safeNotifyListeners();

    try {
      await leaveRoom();

      await Future.delayed(
        const Duration(seconds: 2),
      );

      await initialize();

      _connected = true;
      _reconnecting = false;
      _connectionText = "Connected";
    } catch (e) {
      _connected = false;
      _reconnecting = false;
      _connectionText = "Reconnect Failed";

      debugPrint(
        "Reconnect Error : $e",
      );
    }

    safeNotifyListeners();
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
    _isDisposed = true; 

    messageController.dispose();
    _cancelSubscriptions();
    _messages.clear();
    super.dispose();
  }
}