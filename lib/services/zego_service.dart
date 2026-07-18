import 'dart:async';

import 'package:flutter/foundation.dart';
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
    await ZegoExpressEngine.instance.startPreview();
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
    await ZegoExpressEngine.instance.startPlayingStream(
      streamID,
    );
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

  static Future<void> switchCamera() async {
    _frontCamera = !_frontCamera;

    await ZegoExpressEngine.instance.useFrontCamera(
      _frontCamera,
    );
  }

  ///------------------------------------------------------------
  /// Video Mirror
  ///------------------------------------------------------------

  static Future<void> setVideoMirror(
    bool enable,
  ) async {
    debugPrint(
      "Mirror : $enable",
    );
  }

  ///------------------------------------------------------------
  /// Beauty
  ///------------------------------------------------------------

  static Future<void> enableBeauty(
    bool enable,
  ) async {
    debugPrint(
      "Beauty : $enable",
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
  /// Getters
  ///------------------------------------------------------------

  static String? get currentRoomID => _currentRoomID;

  static String? get currentUserID => _currentUserID;

  static String? get currentUserName => _currentUserName;

  static bool get isEngineInitialized => _initialized;

  static bool get isRoomLoggedIn => _loggedIn;
}