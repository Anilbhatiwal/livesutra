import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../../controllers/live_room_controller.dart';
import '../../../services/zego_service.dart';


class LiveVideoView extends StatefulWidget {

  const LiveVideoView({
    super.key,
  });

  @override
  State<LiveVideoView> createState() =>
      _LiveVideoViewState();
}



class _LiveVideoViewState extends State<LiveVideoView> {

  Widget? _zegoView;

  bool _viewCreated = false;


  @override
  void initState() {
    super.initState();

    _createZegoView();
  }



Future<void> _createZegoView() async {
    debugPrint("CREATE CANVAS VIEW START");

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final view = await ZegoExpressEngine.instance.createCanvasView(
          (viewID) async { // इसे async बनाएं
            debugPrint("Zego Canvas View ID : $viewID");

            await ZegoExpressEngine.instance.setVideoConfig(
              ZegoVideoConfig(
                720,
                1280,
                720,
                1280,
                15,
                1200,
                ZegoVideoCodecID.Default,
              ),
            );

            await ZegoExpressEngine.instance.startPreview(
              canvas: ZegoCanvas.view(viewID),
            );
          },
        );

        if (!mounted) return;

        setState(() {
          _zegoView = view;
          _viewCreated = true;
        });
      } catch (e) {
        debugPrint("Error creating Zego View: $e");
      }
    });
  }



  @override
Widget build(BuildContext context) {
  final controller = context.watch<LiveRoomController>();

  // Positioned.fill को यहाँ से हटाकर सीधे Stack रिटर्न करें
  return Stack(
    children: [
      Container(
        color: Colors.black,
        child: _viewCreated && _zegoView != null
            ? _zegoView!
            : const Center(child: Text("Connecting Video...", style: TextStyle(color: Colors.white38, fontSize: 22))),
      ),



          Positioned(

            top: 50,

            right: 16,

            child: Container(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),


              decoration: BoxDecoration(

                color: Colors.black54,

                borderRadius:
                BorderRadius.circular(20),

              ),


              child: Row(

                children: [


                  Icon(

                    Icons.network_check,

                    color:
                    controller.networkQuality <= 1

                        ? Colors.green

                        : controller.networkQuality == 2

                        ? Colors.orange

                        : Colors.red,

                    size: 18,

                  ),


                  const SizedBox(
                    width: 6,
                  ),


                  Text(

                    "Net ${controller.networkQuality}",

                    style:
                    const TextStyle(

                      color: Colors.white,

                      fontSize: 12,

                    ),

                  ),

                ],

              ),

            ),

          ),



          if (!controller.connected)

            Container(

              color: Colors.black54,

              child: Center(

                child: Text(

                  controller.connectionText,

                  style:
                  const TextStyle(

                    color: Colors.white,

                    fontSize: 18,

                  ),

                ),

              ),

            ),



          if (controller.reconnecting)

            const Center(

              child:
              CircularProgressIndicator(),

            ),


        ],

    );

  }

}