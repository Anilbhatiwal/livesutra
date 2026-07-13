import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoService {
  static const int appID = 1826378765;

  static const String appSign =
      "fa745741653f22c62ed997c8b3de170e1b46ddfe1bf44c874b11791745337f9c";


  static Future<void> init() async {
    final profile = ZegoEngineProfile(
      appID,
      ZegoScenario.Broadcast,
      appSign: appSign,
    );

    await ZegoExpressEngine.createEngineWithProfile(
      profile,
    );
  }


  static Future<void> destroy() async {
    await ZegoExpressEngine.destroyEngine();
  }


  /// Login Live Room

  static Future<void> loginRoom({
    required String roomID,
    required String userID,
    required String userName,
  }) async {

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
  }


  /// Logout Live Room

  static Future<void> logoutRoom(
    String roomID,
  ) async {

    await ZegoExpressEngine.instance.logoutRoom(
      roomID,
    );
  }
    /// Start Camera Preview

  static Future<void> startPreview() async {

    await ZegoExpressEngine.instance.startPreview();
  }


  /// Stop Camera Preview

  static Future<void> stopPreview() async {

    await ZegoExpressEngine.instance.stopPreview();
  }



  /// Start Host Live Stream

  static Future<void> startPublishing({
    required String streamID,
  }) async {

    await ZegoExpressEngine.instance.startPublishingStream(
      streamID,
    );
  }



  /// Stop Host Live Stream

  static Future<void> stopPublishing() async {

    await ZegoExpressEngine.instance.stopPublishingStream();
  }



  /// Start Viewer Stream

  static Future<void> startPlaying({
    required String streamID,
  }) async {

    await ZegoExpressEngine.instance.startPlayingStream(
      streamID,
    );
  }



  /// Stop Viewer Stream

  static Future<void> stopPlaying({
    required String streamID,
  }) async {

    await ZegoExpressEngine.instance.stopPlayingStream(
      streamID,
    );
  }



  /// Enable / Disable Camera

  static Future<void> enableCamera(
    bool enable,
  ) async {

    await ZegoExpressEngine.instance.enableCamera(
      enable,
    );
  }



  /// Enable / Disable Microphone

  static Future<void> enableMicrophone(
    bool enable,
  ) async {

    await ZegoExpressEngine.instance.muteMicrophone(!enable);
  }
    /// Enable / Disable Speaker

  static Future<void> enableSpeaker(
    bool enable,
  ) async {

    await ZegoExpressEngine.instance.muteSpeaker(!enable);
  }



  /// Switch Front / Back Camera

  static Future<void> switchCamera() async {

    await ZegoExpressEngine.instance.useFrontCamera(true);
  }



  static Future<void> setVideoMirror(
    bool enable,
  ) async {


  }



  static Future<void> enableBeauty(
    bool enable,
  ) async {

    }
  }