import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

enum ZegoEngineStatus {
  notInitialized,
  initializing,
  initialized,
  destroying,
  destroyed,
}

class ZegoService {
  ZegoService._();

  //==============================================================
  // App Configuration
  //==============================================================

  static const int appID = 1826378765;

  static const String appSign =
      "fa745741653f22c62ed997c8b3de170e1b46ddfe1bf44c874b11791745337f9c";

  //==============================================================
  // Engine State
  //==============================================================

  static ZegoEngineStatus _engineStatus =
      ZegoEngineStatus.notInitialized;

  static bool _initialized = false;

  static bool _loggedIn = false;

  static bool _initializing = false;

  static bool _destroying = false;

  //==============================================================
  // Room Information
  //==============================================================

  static String? _currentRoomID;

  static String? _currentUserID;

  static String? _currentUserName;

  //==============================================================
  // Stream Information
  //==============================================================

  static String? _currentPublishStreamID;

  static final Set<String> _playingStreams = {};

  //==============================================================
  // Video Views
  //==============================================================

  static int? _localViewID;

  static Widget? _localPreviewWidget;

  static bool _previewStarted = false;

  static final Map<String, int> _remoteViewIDs = {};

  static final Map<String, Widget?> _remoteWidgets = {};

  //==============================================================
  // Device State
  //==============================================================

  static bool _cameraEnabled = true;

  static bool _microphoneEnabled = true;

  static bool _speakerEnabled = true;

  static bool _frontCamera = true;

  static bool _beautyEnabled = false;

  static bool _mirrorEnabled = false;

  //==============================================================
  // Video Configuration
  //==============================================================

  static int _videoWidth = 720;

  static int _videoHeight = 1280;

  static int _videoFPS = 30;

  static int _videoBitrate = 1800;

  //==============================================================
  // Logger
  //==============================================================

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint("[ZEGO] $message");
    }
  }

  static void _logError(Object error) {
    if (kDebugMode) {
      debugPrint("[ZEGO ERROR] $error");
    }
  }

  //==============================================================
  // Engine Status
  //==============================================================

  static bool get isInitialized => _initialized;

  static bool get isLoggedIn => _loggedIn;

  static ZegoEngineStatus get engineStatus =>
      _engineStatus;

  //==============================================================
  // Initialize Engine
  //==============================================================

  static Future<void> init() async {
    if (_initialized) {
      _log("Engine already initialized.");
      return;
    }

    if (_initializing) {
      _log("Engine initialization already running.");
      return;
    }

    _initializing = true;

    _engineStatus = ZegoEngineStatus.initializing;

    try {
      final profile = ZegoEngineProfile(
        appID,
        ZegoScenario.Broadcast,
        appSign: appSign,
      );

      await ZegoExpressEngine.createEngineWithProfile(
        profile,
      );

      _initialized = true;

      _engineStatus =
          ZegoEngineStatus.initialized;

      _log("Engine initialized successfully.");
    } catch (e) {
      _logError(e);

      _initialized = false;

      _engineStatus =
          ZegoEngineStatus.notInitialized;

      rethrow;
    } finally {
      _initializing = false;
    }
  }
  //==============================================================
  // Destroy Engine
  //==============================================================

  static Future<void> destroy() async {
    if (!_initialized) return;

    if (_destroying) return;

    _destroying = true;

    _engineStatus = ZegoEngineStatus.destroying;

    try {
      if (_loggedIn && _currentRoomID != null) {
        await logoutRoom(_currentRoomID!);
      }

      if (_localViewID != null) {
        try {
          await ZegoExpressEngine.instance
              .destroyCanvasView(_localViewID!);
        } catch (_) {}

        _localViewID = null;
      }

      for (final viewID in _remoteViewIDs.values) {
        try {
          await ZegoExpressEngine.instance
              .destroyCanvasView(viewID);
        } catch (_) {}
      }

      _remoteViewIDs.clear();
      _remoteWidgets.clear();
      _playingStreams.clear();

      await ZegoExpressEngine.destroyEngine();

      _initialized = false;

      _engineStatus = ZegoEngineStatus.destroyed;

      _log("Engine destroyed successfully.");
    } catch (e) {
      _logError(e);
      rethrow;
    } finally {
      _destroying = false;
    }
  }

  //==============================================================
  // Reset
  //==============================================================

  static void reset() {
    _loggedIn = false;

    _currentRoomID = null;
    _currentUserID = null;
    _currentUserName = null;

    _currentPublishStreamID = null;

    _playingStreams.clear();

    _localViewID = null;

    _localPreviewWidget = null;

    _remoteViewIDs.clear();

    _remoteWidgets.clear();

    _cameraEnabled = true;
    _microphoneEnabled = true;
    _speakerEnabled = true;
    _frontCamera = true;
    _beautyEnabled = false;
    _mirrorEnabled = false;

    _videoWidth = 720;
    _videoHeight = 1280;
    _videoFPS = 30;
    _videoBitrate = 1800;

    _engineStatus = ZegoEngineStatus.notInitialized;
  }

  //==============================================================
  // Login Room
  //==============================================================

  static Future<void> loginRoom({
    required String roomID,
    required String userID,
    required String userName,
  }) async {
    if (!_initialized) {
      await init();
    }

    if (_loggedIn && _currentRoomID == roomID) {
      _log("Already logged into room.");
      return;
    }

    final user = ZegoUser(
      userID,
      userName,
    );

    final config = ZegoRoomConfig(
      0,
      true,
      '',
    );

    await ZegoExpressEngine.instance.loginRoom(
      roomID,
      user,
      config: config,
    );

    _loggedIn = true;

    _currentRoomID = roomID;
    _currentUserID = userID;
    _currentUserName = userName;

    _log("Room login success : $roomID");
  }

  //==============================================================
  // Logout Room
  //==============================================================

  static Future<void> logoutRoom(
    String roomID,
  ) async {
    if (!_loggedIn) return;

    try {
      await ZegoExpressEngine.instance.logoutRoom(
        roomID,
      );

      _loggedIn = false;

      _currentRoomID = null;
      _currentUserID = null;
      _currentUserName = null;

      _currentPublishStreamID = null;

      _playingStreams.clear();

      _log("Room logout success.");
    } catch (e) {
      _logError(e);
      rethrow;
    }
  }
    //==============================================================
  // Create Local Preview Canvas
  //==============================================================

  static Future<Widget?> createLocalPreview() async {
    if (!_initialized) {
      await init();
    }

    if (_localPreviewWidget != null) {
      return _localPreviewWidget;
    }

    try {
      _localPreviewWidget =
          await ZegoExpressEngine.instance.createCanvasView(
        (viewID) async {
          _localViewID = viewID;

          final canvas = ZegoCanvas.view(viewID);

          await ZegoExpressEngine.instance.startPreview(
            canvas: canvas,
          );
        },
      );

      _log("Local preview created.");

      return _localPreviewWidget;
    } catch (e) {
      _logError(e);
      return null;
    }
  }

  //==============================================================
  // Start Preview
  //==============================================================

  static Future<Widget?> startPreview() async {
  if (!_initialized) {
    await init();
  }

  if (_previewStarted && _localPreviewWidget != null) {
    return _localPreviewWidget;
  }

  _localPreviewWidget =
      await ZegoExpressEngine.instance.createCanvasView(
    (viewID) async {
      _localViewID = viewID;
    },
  );

  if (_localViewID != null) {
    final canvas = ZegoCanvas.view(_localViewID!);

    await ZegoExpressEngine.instance.startPreview(
      canvas: canvas,
    );

    _previewStarted = true;
  }

  return _localPreviewWidget;
}
  //==============================================================
  // Stop Preview
  //==============================================================

  static Future<void> stopPreview() async {
    try {
      await ZegoExpressEngine.instance.stopPreview();

      _previewStarted = false;

      if (_localViewID != null) {
        await ZegoExpressEngine.instance.destroyCanvasView(
          _localViewID!,
        );

        _localViewID = null;
      }

      _localPreviewWidget = null;

      _log("Preview stopped.");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Start Publishing
  //==============================================================

  static Future<void> startPublishing({
    required String streamID,
  }) async {
    if (!_loggedIn) {
      throw Exception(
        "Please login room before publishing.",
      );
    }

    try {
      _currentPublishStreamID = streamID;

      await ZegoExpressEngine.instance
          .startPublishingStream(
        streamID,
      );

      _log("Publishing started : $streamID");
    } catch (e) {
      _currentPublishStreamID = null;

      _logError(e);

      rethrow;
    }
  }

  //==============================================================
  // Stop Publishing
  //==============================================================

  static Future<void> stopPublishing() async {
    try {
      await ZegoExpressEngine.instance
          .stopPublishingStream();

      _currentPublishStreamID = null;

      _log("Publishing stopped.");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Is Publishing
  //==============================================================

  static bool get isPublishing =>
      _currentPublishStreamID != null;
        //==============================================================
  // Create Remote Canvas
  //==============================================================

  static Future<Widget?> createRemoteView({
    required String streamID,
  }) async {
    if (_remoteWidgets.containsKey(streamID)) {
      return _remoteWidgets[streamID];
    }

    try {
      final widget =
          await ZegoExpressEngine.instance.createCanvasView(
        (viewID) async {
          _remoteViewIDs[streamID] = viewID;

          final canvas = ZegoCanvas.view(viewID);

          await ZegoExpressEngine.instance.startPlayingStream(
            streamID,
            canvas: canvas,
          );

          _playingStreams.add(streamID);
        },
      );

      _remoteWidgets[streamID] = widget;

      _log("Remote canvas created : $streamID");

      return widget;
    } catch (e) {
      _logError(e);
      return null;
    }
  }

  //==============================================================
  // Start Playing
  //==============================================================

  static Future<void> startPlaying({
    required String streamID,
  }) async {
    if (_playingStreams.contains(streamID)) {
      return;
    }

    try {
      if (_remoteViewIDs.containsKey(streamID)) {
        final canvas = ZegoCanvas.view(
          _remoteViewIDs[streamID]!,
        );

        await ZegoExpressEngine.instance.startPlayingStream(
          streamID,
          canvas: canvas,
        );

        _playingStreams.add(streamID);

        _log("Playing started : $streamID");
      } else {
        await createRemoteView(
          streamID: streamID,
        );
      }
    } catch (e) {
      _logError(e);
      rethrow;
    }
  }

  //==============================================================
  // Stop Playing
  //==============================================================

  static Future<void> stopPlaying({
    required String streamID,
  }) async {
    try {
      await ZegoExpressEngine.instance.stopPlayingStream(
        streamID,
      );

      if (_remoteViewIDs.containsKey(streamID)) {
        await ZegoExpressEngine.instance.destroyCanvasView(
          _remoteViewIDs[streamID]!,
        );

        _remoteViewIDs.remove(streamID);
      }

      _remoteWidgets.remove(streamID);

      _playingStreams.remove(streamID);

      _log("Playing stopped : $streamID");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Stop All Playing Streams
  //==============================================================

  static Future<void> stopAllPlaying() async {
    final streams = List<String>.from(
      _playingStreams,
    );

    for (final streamID in streams) {
      await stopPlaying(
        streamID: streamID,
      );
    }
  }

  //==============================================================
  // Get Remote Widget
  //==============================================================

  static Widget? getRemoteWidget(
    String streamID,
  ) {
    return _remoteWidgets[streamID];
  }

  //==============================================================
  // Is Playing
  //==============================================================

  static bool isPlaying(
    String streamID,
  ) {
    return _playingStreams.contains(streamID);
  }
    //==============================================================
  // Camera
  //==============================================================

  static Future<void> enableCamera(
    bool enable,
  ) async {
    try {
      _cameraEnabled = enable;

      await ZegoExpressEngine.instance.enableCamera(
        enable,
      );

      _log("Camera : $enable");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Microphone
  //==============================================================

  static Future<void> enableMicrophone(
    bool enable,
  ) async {
    try {
      _microphoneEnabled = enable;

      await ZegoExpressEngine.instance.muteMicrophone(
        !enable,
      );

      _log("Microphone : $enable");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Speaker
  //==============================================================

  static Future<void> enableSpeaker(
    bool enable,
  ) async {
    try {
      _speakerEnabled = enable;

      await ZegoExpressEngine.instance.muteSpeaker(
        !enable,
      );

      _log("Speaker : $enable");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Switch Camera
  //==============================================================

  static Future<void> switchCamera() async {
    try {
      _frontCamera = !_frontCamera;

      await ZegoExpressEngine.instance.useFrontCamera(
        _frontCamera,
      );

      _log(
        _frontCamera
            ? "Front Camera"
            : "Rear Camera",
      );
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Video Mirror
  //==============================================================

  static Future<void> setVideoMirror(
    bool enable,
  ) async {
    try {
      _mirrorEnabled = enable;

      // Add SDK mirror API here if required.

      _log("Mirror : $enable");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Beauty
  //==============================================================

  static Future<void> enableBeauty(
    bool enable,
  ) async {
    try {
      _beautyEnabled = enable;

      // Add Zego Effects / Beauty SDK integration here.

      _log("Beauty : $enable");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Device Getters
  //==============================================================

  static bool get isCameraEnabled =>
      _cameraEnabled;

  static bool get isMicrophoneEnabled =>
      _microphoneEnabled;

  static bool get isSpeakerEnabled =>
      _speakerEnabled;

  static bool get isBeautyEnabled =>
      _beautyEnabled;

  static bool get isMirrorEnabled =>
      _mirrorEnabled;

  static bool get isFrontCamera =>
      _frontCamera;
        //==============================================================
  // Video Configuration
  //==============================================================

  static Future<void> setVideoConfig({
    int width = 720,
    int height = 1280,
    int fps = 30,
    int bitrate = 1800,
  }) async {
    try {
      _videoWidth = width;
      _videoHeight = height;
      _videoFPS = fps;
      _videoBitrate = bitrate;

      final config = ZegoVideoConfig(
        width,
        height,
        width,
        height,
        fps,
        bitrate,
        ZegoVideoCodecID.Default,
      );

      await ZegoExpressEngine.instance.setVideoConfig(
        config,
      );

      _log(
        "Video Config : "
        "${width}x$height "
        "FPS:$fps "
        "Bitrate:$bitrate",
      );
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // HD
  //==============================================================

  static Future<void> enableHD() async {
    await setVideoConfig(
      width: 720,
      height: 1280,
      fps: 30,
      bitrate: 1800,
    );
  }

  //==============================================================
  // Full HD
  //==============================================================

  static Future<void> enableFullHD() async {
    await setVideoConfig(
      width: 1080,
      height: 1920,
      fps: 30,
      bitrate: 2500,
    );
  }

  //==============================================================
  // Low Network
  //==============================================================

  static Future<void> enableLowNetworkMode() async {
    await setVideoConfig(
      width: 360,
      height: 640,
      fps: 15,
      bitrate: 500,
    );
  }

  //==============================================================
  // Custom Video Profile
  //==============================================================

  static Future<void> setCustomVideoProfile({
    required int width,
    required int height,
    required int fps,
    required int bitrate,
  }) async {
    await setVideoConfig(
      width: width,
      height: height,
      fps: fps,
      bitrate: bitrate,
    );
  }

  //==============================================================
  // Video Getters
  //==============================================================

  static int get videoWidth =>
      _videoWidth;

  static int get videoHeight =>
      _videoHeight;

  static int get videoFPS =>
      _videoFPS;

  static int get videoBitrate =>
      _videoBitrate;

  //==============================================================
  // Current Information
  //==============================================================

  static String? get currentRoomID =>
      _currentRoomID;

  static String? get currentUserID =>
      _currentUserID;

  static String? get currentUserName =>
      _currentUserName;

  static String? get currentPublishStreamID =>
      _currentPublishStreamID;
        //==============================================================
  // Register Event Callbacks
  //==============================================================

  static void registerCallbacks({
    VoidCallback? onRoomConnected,
    VoidCallback? onRoomDisconnected,
    VoidCallback? onPublishStarted,
    VoidCallback? onPublishStopped,
    VoidCallback? onPlayStarted,
    VoidCallback? onPlayStopped,
    ValueChanged<ZegoStreamQualityLevel>? onPublishQuality,
    ValueChanged<ZegoStreamQualityLevel>? onPlayQuality,
    ValueChanged<List<ZegoUser>>? onUsersUpdated,
    ValueChanged<List<ZegoStream>>? onStreamsUpdated,
    ValueChanged<String>? onBroadcastMessage,
    ValueChanged<String>? onBarrageMessage,
  }) {
    ZegoExpressEngine.onRoomStateUpdate = (
      String roomID,
      ZegoRoomState state,
      int errorCode,
      Map<String, dynamic> extendedData,
    ) {
      _log(
        "Room State : $state  Error : $errorCode",
      );

      switch (state) {
        case ZegoRoomState.Connected:
          onRoomConnected?.call();
          break;

        case ZegoRoomState.Disconnected:
          onRoomDisconnected?.call();
          break;

        default:
          break;
      }
    };

    ZegoExpressEngine.onPublisherStateUpdate = (
      String streamID,
      ZegoPublisherState state,
      int errorCode,
      Map<String, dynamic> extendedData,
    ) {
      _log(
        "Publisher : $state  Error : $errorCode",
      );

      if (state == ZegoPublisherState.Publishing) {
        onPublishStarted?.call();
      }

      if (state == ZegoPublisherState.NoPublish) {
        onPublishStopped?.call();
      }
    };

    ZegoExpressEngine.onPlayerStateUpdate = (
      String streamID,
      ZegoPlayerState state,
      int errorCode,
      Map<String, dynamic> extendedData,
    ) {
      _log(
        "Player : $state  Error : $errorCode",
      );

      if (state == ZegoPlayerState.Playing) {
        onPlayStarted?.call();
      }

      if (state == ZegoPlayerState.NoPlay) {
        onPlayStopped?.call();
      }
    };

    ZegoExpressEngine.onNetworkQuality = (
      String userID,
      ZegoStreamQualityLevel upstreamQuality,
      ZegoStreamQualityLevel downstreamQuality,
    ) {
      onPublishQuality?.call(
        upstreamQuality,
      );

      onPlayQuality?.call(
        downstreamQuality,
      );
    };

    ZegoExpressEngine.onRoomUserUpdate = (
      String roomID,
      ZegoUpdateType updateType,
      List<ZegoUser> userList,
    ) {
      _log(
        "Users Updated : ${userList.length}",
      );

      onUsersUpdated?.call(
        userList,
      );
    };

    ZegoExpressEngine.onRoomStreamUpdate = (
      String roomID,
      ZegoUpdateType updateType,
      List<ZegoStream> streamList,
      Map<String, dynamic> extendedData,
    ) {
      _log(
        "Streams Updated : ${streamList.length}",
      );

      onStreamsUpdated?.call(
        streamList,
      );
    };

    ZegoExpressEngine.onIMRecvBroadcastMessage = (
      String roomID,
      List<ZegoBroadcastMessageInfo> messageList,
    ) {
      for (final message in messageList) {
        onBroadcastMessage?.call(
          message.message,
        );
      }
    };

    ZegoExpressEngine.onIMRecvBarrageMessage = (
      String roomID,
      List<ZegoBarrageMessageInfo> messageList,
    ) {
      for (final message in messageList) {
        onBarrageMessage?.call(
          message.message,
        );
      }
    };
  }
    //==============================================================
  // Unregister Callbacks
  //==============================================================

  static void unregisterCallbacks() {
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
    ZegoExpressEngine.onNetworkQuality = null;
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onIMRecvBroadcastMessage = null;
    ZegoExpressEngine.onIMRecvBarrageMessage = null;
  }

  //==============================================================
  // Send Broadcast Message
  //==============================================================

  static Future<void> sendBroadcastMessage(
    String message,
  ) async {
    if (!_loggedIn || _currentRoomID == null) {
      return;
    }

    try {
      await ZegoExpressEngine.instance
          .sendBroadcastMessage(
        _currentRoomID!,
        message,
      );

      _log("Broadcast Message Sent");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Send Barrage Message
  //==============================================================

  static Future<void> sendBarrageMessage(
    String message,
  ) async {
    if (!_loggedIn || _currentRoomID == null) {
      return;
    }

    try {
      await ZegoExpressEngine.instance
          .sendBarrageMessage(
        _currentRoomID!,
        message,
      );

      _log("Barrage Message Sent");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Stop Everything
  //==============================================================

  static Future<void> stopAll() async {
    try {
      await stopPreview();
    } catch (_) {}

    try {
      await stopPublishing();
    } catch (_) {}

    try {
      await stopAllPlaying();
    } catch (_) {}
  }

  //==============================================================
  // Leave Room
  //==============================================================

  static Future<void> leaveRoom() async {
    try {
      await stopAll();

      if (_currentRoomID != null) {
        await logoutRoom(
          _currentRoomID!,
        );
      }

      _log("Leave Room Success");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Dispose
  //==============================================================

  static Future<void> dispose() async {
    try {
      unregisterCallbacks();

      await leaveRoom();

      reset();

      await destroy();

      _log("Service Disposed");
    } catch (e) {
      _logError(e);
    }
  }

  //==============================================================
  // Utility Getters
  //==============================================================

  static Widget? get localPreviewWidget =>
      _localPreviewWidget;

  static bool get hasLocalPreview =>
      _localPreviewWidget != null;

  static bool get hasPublishedStream =>
      _currentPublishStreamID != null;

  static List<String> get playingStreams =>
      _playingStreams.toList(growable: false);

  static bool get isEngineReady =>
      _initialized &&
      _engineStatus ==
          ZegoEngineStatus.initialized;
}