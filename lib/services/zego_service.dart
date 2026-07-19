import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';


class ZegoService {
  ZegoService._();

  static const int appID = 1826378765;

  static const String appSign =
      "fa745741653f22c62ed997c8b3de170e1b46ddfe1bf44c874b11791745337f9c";

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static bool _loggedIn = false;

  static bool get isLoggedIn => _loggedIn;

  static String? _currentRoomID;

  static String? _currentUserID;

  static String? _currentUserName;

  static Future<void> init() async {
    if (_initialized) return;

    final profile = ZegoEngineProfile(
      appID,
      ZegoScenario.Broadcast,
      appSign: appSign,
    );

    await ZegoExpressEngine.createEngineWithProfile(
      profile,
    );

    _initialized = true;

    debugPrint(
      "Zego Engine Initialized",
    );
  }

  static Future<void> destroy() async {
    if (!_initialized) return;

    try {
      if (_loggedIn && _currentRoomID != null) {
        await logoutRoom(
          _currentRoomID!,
        );
      }
    } catch (_) {}

    await ZegoExpressEngine.destroyEngine();

    _initialized = false;
    _loggedIn = false;

    _currentRoomID = null;
    _currentUserID = null;
    _currentUserName = null;

    debugPrint(
      "Zego Engine Destroyed",
    );
  }
    ///------------------------------------------------------------
  /// Login Room
  ///------------------------------------------------------------

  static Future<void> loginRoom({
    required String roomID,
    required String userID,
    required String userName,
  }) async {
    if (!_initialized) {
      await init();
    }

    if (_loggedIn && _currentRoomID == roomID) {
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

    debugPrint(
      "Room Login Success : $roomID",
    );
  }

  ///------------------------------------------------------------
  /// Logout Room
  ///------------------------------------------------------------

  static Future<void> logoutRoom(
    String roomID,
  ) async {
    if (!_loggedIn) return;

    await ZegoExpressEngine.instance.logoutRoom(
      roomID,
    );

    _loggedIn = false;

    _currentRoomID = null;
    _currentUserID = null;
    _currentUserName = null;

    debugPrint(
      "Room Logout Success",
    );
  }

  ///------------------------------------------------------------
  /// Start Preview
  ///------------------------------------------------------------

  static Future<void> startPreview() async {
  final canvas = ZegoCanvas.view(0);

  await ZegoExpressEngine.instance.startPreview(
    canvas: canvas,
  );

  _localViewID = 0;
}

  ///------------------------------------------------------------
  /// Stop Preview
  ///------------------------------------------------------------

  static Future<void> stopPreview() async {
    await ZegoExpressEngine.instance.stopPreview();
  }

  ///------------------------------------------------------------
  /// Start Publishing
  ///------------------------------------------------------------

  static Future<void> startPublishing({
    required String streamID,
  }) async {
    await ZegoExpressEngine.instance.startPublishingStream(
      streamID,
    );
  }

  ///------------------------------------------------------------
  /// Stop Publishing
  ///------------------------------------------------------------

  static Future<void> stopPublishing() async {
    await ZegoExpressEngine.instance.stopPublishingStream();
  }

  ///------------------------------------------------------------
  /// Start Playing
  ///------------------------------------------------------------

  static Future<void> startPlaying({
  required String streamID,
}) async {
  final canvas = ZegoCanvas.view(0);

  await ZegoExpressEngine.instance.startPlayingStream(
    streamID,
    canvas: canvas,
  );

  _remoteViews[streamID] = 0;
}

  ///------------------------------------------------------------
  /// Stop Playing
  ///------------------------------------------------------------

  static Future<void> stopPlaying({
    required String streamID,
  }) async {
    await ZegoExpressEngine.instance.stopPlayingStream(
      streamID,
    );
  }
    ///------------------------------------------------------------
  /// Camera
  ///------------------------------------------------------------

  static Future<void> enableCamera(
    bool enable,
  ) async {
    await ZegoExpressEngine.instance.enableCamera(
      enable,
    );
  }

  ///------------------------------------------------------------
  /// Microphone
  ///------------------------------------------------------------

  static Future<void> enableMicrophone(
    bool enable,
  ) async {
    await ZegoExpressEngine.instance.muteMicrophone(
      !enable,
    );
  }

  ///------------------------------------------------------------
  /// Speaker
  ///------------------------------------------------------------

  static Future<void> enableSpeaker(
    bool enable,
  ) async {
    await ZegoExpressEngine.instance.muteSpeaker(
      !enable,
    );
  }

  ///------------------------------------------------------------
  /// Switch Camera
  ///------------------------------------------------------------

  static bool _frontCamera = true;

  static bool _cameraEnabled = true;
static bool _microphoneEnabled = true;
static bool _speakerEnabled = true;

static bool _beautyEnabled = false;
static bool _mirrorEnabled = false;

static int _videoWidth = 720;
static int _videoHeight = 1280;
static int _videoFps = 30;
static int _videoBitrate = 1500;

static int? _localViewID;

static final Map<String, int> _remoteViews = {};

  static Future<void> switchCamera() async {
    _frontCamera = !_frontCamera;

    await ZegoExpressEngine.instance.useFrontCamera(
      _frontCamera,
    );
  }

  //======================================================
// Video Configuration
//======================================================

static Future<void> setVideoConfig({
  int width = 720,
  int height = 1280,
  int fps = 15,
  int bitrate = 1200,
}) async {
  final config = ZegoVideoConfig(
    width,      // captureWidth
    height,     // captureHeight
    width,      // encodeWidth
    height,     // encodeHeight
    fps,        // FPS
    bitrate,    // Bitrate
    ZegoVideoCodecID.Default,
  );

  await ZegoExpressEngine.instance.setVideoConfig(config);

  debugPrint(
    "Video Config : ${width}x$height  FPS:$fps  Bitrate:$bitrate",
  );
}

static Future<void> enableHD() async {
  await setVideoConfig(
    width: 720,
    height: 1280,
    fps: 30,
    bitrate: 1800,
  );
}

static Future<void> enableFullHD() async {
  await setVideoConfig(
    width: 1080,
    height: 1920,
    fps: 30,
    bitrate: 2500,
  );
}

static Future<void> enableLowNetworkMode() async {
  await setVideoConfig(
    width: 360,
    height: 640,
    fps: 15,
    bitrate: 500,
  );
}

  ///------------------------------------------------------------
  /// Video Mirror
  ///------------------------------------------------------------

  static Future<void> setVideoMirror(
  bool enable,
) async {
  _mirrorEnabled = enable;

  debugPrint(
    "Mirror : $_mirrorEnabled",
  );
}

  ///------------------------------------------------------------
  /// Beauty
  ///------------------------------------------------------------

  static Future<void> enableBeauty(
  bool enable,
) async {
  _beautyEnabled = enable;

  debugPrint(
    "Beauty : $_beautyEnabled",
  );
}

  ///------------------------------------------------------------
  /// Event Callbacks
  ///------------------------------------------------------------

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
    ZegoExpressEngine.onRoomStateUpdate =
        (
      String roomID,
      ZegoRoomState state,
      int errorCode,
      Map<String, dynamic> extendedData,
    ) {
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
  onPublishQuality?.call(upstreamQuality);
  onPlayQuality?.call(downstreamQuality);
};
ZegoExpressEngine.onRoomUserUpdate = (
  String roomID,
  ZegoUpdateType updateType,
  List<ZegoUser> userList,
) {
  onUsersUpdated?.call(userList);
};
ZegoExpressEngine.onRoomStreamUpdate = (
  String roomID,
  ZegoUpdateType updateType,
  List<ZegoStream> streamList,
  Map<String, dynamic> extendedData,
) {
  onStreamsUpdated?.call(streamList);
};
ZegoExpressEngine.onIMRecvBroadcastMessage = (
  String roomID,
  List<ZegoBroadcastMessageInfo> messageList,
) {
  for (final message in messageList) {
    onBroadcastMessage?.call(message.message);
  }
};
ZegoExpressEngine.onIMRecvBarrageMessage = (
  String roomID,
  List<ZegoBarrageMessageInfo> messageList,
) {
  for (final message in messageList) {
    onBarrageMessage?.call(message.message);
  }
};
  }
    ///------------------------------------------------------------
  /// Unregister Callbacks
  ///------------------------------------------------------------

  static void unregisterCallbacks() {
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
  }

  ///------------------------------------------------------------
  /// Stop Everything
  ///------------------------------------------------------------

  static Future<void> stopAll() async {
    try {
      await stopPreview();
    } catch (_) {}

    try {
      await stopPublishing();
    } catch (_) {}

    try {
      if (_currentRoomID != null) {
        await stopPlaying(
          streamID: _currentRoomID!,
        );
      }
    } catch (_) {}
  }

///------------------------------------------------------------
/// Send Broadcast Message
///------------------------------------------------------------

static Future<void> sendBroadcastMessage(
  String message,
) async {
  if (!_loggedIn || _currentRoomID == null) return;

  await ZegoExpressEngine.instance.sendBroadcastMessage(
    _currentRoomID!,
    message,
  );
}

///------------------------------------------------------------
/// Send Barrage Message
///------------------------------------------------------------

static Future<void> sendBarrageMessage(
  String message,
) async {
  if (!_loggedIn || _currentRoomID == null) return;

  await ZegoExpressEngine.instance.sendBarrageMessage(
    _currentRoomID!,
    message,
  );
}

  ///------------------------------------------------------------
  /// Leave Room
  ///------------------------------------------------------------

  static Future<void> leaveRoom() async {
    try {
      await stopAll();

      if (_currentRoomID != null) {
        await logoutRoom(
          _currentRoomID!,
        );
      }
    } catch (e) {
      debugPrint(
        "Leave Room Error : $e",
      );
    }
  }

  ///------------------------------------------------------------
  /// Reset Local State
  ///------------------------------------------------------------

  static void reset() {
    _loggedIn = false;

    _currentRoomID = null;
    _currentUserID = null;
    _currentUserName = null;

    _frontCamera = true;
  }

  ///------------------------------------------------------------
  /// Dispose Service
  ///------------------------------------------------------------

  static Future<void> dispose() async {
    try {
      unregisterCallbacks();

      await leaveRoom();

      reset();

      await destroy();
    } catch (e) {
      debugPrint(
        "Zego Dispose Error : $e",
      );
    }
  }

///------------------------------------------------------------
/// Is Camera Enabled
///------------------------------------------------------------

static bool get isCameraEnabled => _cameraEnabled;

///------------------------------------------------------------
/// Is Microphone Enabled
///------------------------------------------------------------

static bool get isMicrophoneEnabled => _microphoneEnabled;

///------------------------------------------------------------
/// Is Speaker Enabled
///------------------------------------------------------------

static bool get isSpeakerEnabled => _speakerEnabled;

///------------------------------------------------------------
/// Is Beauty Enabled
///------------------------------------------------------------

static bool get isBeautyEnabled => _beautyEnabled;

///------------------------------------------------------------
/// Is Mirror Enabled
///------------------------------------------------------------

static bool get isMirrorEnabled => _mirrorEnabled;

  ///------------------------------------------------------------
  /// Getters
  ///------------------------------------------------------------

  static String? get currentRoomID => _currentRoomID;

  static String? get currentUserID => _currentUserID;

  static String? get currentUserName => _currentUserName;

  static bool get isEngineInitialized => _initialized;

  static bool get isRoomLoggedIn => _loggedIn;
}