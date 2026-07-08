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

    await ZegoExpressEngine.createEngineWithProfile(profile);
  }

  static Future<void> destroy() async {
    await ZegoExpressEngine.destroyEngine();
  }
}