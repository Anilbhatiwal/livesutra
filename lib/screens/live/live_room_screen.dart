import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../../controllers/live_room_controller.dart';
import '../../models/live_model.dart';


class LiveRoomScreen extends StatefulWidget {


  const LiveRoomScreen({

    super.key,

    required this.live,

    required this.userId,

    required this.userName,

    required this.isHost,

  });



  final LiveModel live;


  final String userId;


  final String userName;


  final bool isHost;




  @override
  State<LiveRoomScreen> createState() =>
      _LiveRoomScreenState();

}





class _LiveRoomScreenState
    extends State<LiveRoomScreen> {



  late LiveRoomController controller;




  @override
  void initState() {

    super.initState();



    controller =
        LiveRoomController(

          live: widget.live,

          userId: widget.userId,

          userName: widget.userName,

          isHost: widget.isHost,

        );



    controller.initialize();



    controller.registerZegoCallbacks();


  }





  @override
  void dispose() {


    controller.dispose();


    super.dispose();


  }





  @override
  Widget build(BuildContext context) {



    return ChangeNotifierProvider.value(


      value: controller,



      child: Scaffold(


        backgroundColor: Colors.black,



        body: Consumer<LiveRoomController>(


          builder:
              (context, liveController, child) {



            if(!liveController.isInitialized){


              return const Center(

                child:
                    CircularProgressIndicator(

                  color: Colors.white,

                ),

              );

            }




            return Stack(

              children: [



                Positioned.fill(

                  child:

                  _buildVideoView(),

                ),




                Positioned(

                  top: 0,

                  left: 0,

                  right: 0,

                  child:

                  _buildTopBar(

                    liveController,

                  ),

                ),




                Positioned(

                  left: 0,

                  right: 0,

                  bottom: 0,

                  child:

                  _buildBottomControls(

                    liveController,

                  ),

                ),


              ],

            );



          },

        ),

      ),

    );


  }





  Widget _buildVideoView() {
    return FutureBuilder<Widget?>(
      future: ZegoExpressEngine.instance.createCanvasView((viewID) {
        if (widget.isHost) {
          // Host ke liye local camera preview
          ZegoExpressEngine.instance.startPreview(
            canvas: ZegoCanvas(viewID),
          );
        } else {
          // Audience/Viewer ke liye host ki stream play karna
          ZegoExpressEngine.instance.startPlayingStream(
            widget.live.streamId, // Agar aapke LiveModel mein stream id ka naam alag hai to vo likhein (e.g. widget.live.streamId)
            canvas: ZegoCanvas(viewID),
          );
        }
      }),
      builder: (context, AsyncSnapshot<Widget?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        return Container(
          color: Colors.black,
          child: snapshot.data!,
        );
      },
    );
  }
    Widget _buildTopBar(
      LiveRoomController liveController,
      ) {


    return SafeArea(

      child: Padding(

        padding:
        const EdgeInsets.all(12),


        child: Row(


          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,



          children: [



            Container(

              padding:
              const EdgeInsets.symmetric(

                horizontal: 12,

                vertical: 8,

              ),


              decoration:
              BoxDecoration(

                color:
                Colors.black54,


                borderRadius:
                BorderRadius.circular(20),

              ),



              child: Row(


                children: [



                  CircleAvatar(

                    radius: 16,


                    backgroundColor:
                    Colors.white24,


                    child: Text(

                      widget.userName.isNotEmpty

                          ? widget.userName[0]

                          : "U",


                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                      ),

                    ),

                  ),



                  const SizedBox(

                    width: 8,

                  ),



                  Text(

                    widget.userName,


                    style:
                    const TextStyle(

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),


                ],

              ),

            ),




            Row(

              children: [



                Container(

                  padding:
                  const EdgeInsets.symmetric(

                    horizontal: 12,

                    vertical: 8,

                  ),


                  decoration:
                  BoxDecoration(

                    color:
                    Colors.black54,


                    borderRadius:
                    BorderRadius.circular(20),

                  ),



                  child: Row(

                    children: [



                      const Icon(

                        Icons.people,

                        color:
                        Colors.white,

                        size:
                        18,

                      ),



                      const SizedBox(

                        width: 5,

                      ),



                      Text(

                        liveController
                            .viewerCount
                            .toString(),


                        style:
                        const TextStyle(

                          color:
                          Colors.white,

                        ),

                      ),


                    ],

                  ),

                ),




                const SizedBox(

                  width: 8,

                ),



                GestureDetector(


                  onTap: (){


                    controller.leaveLive();


                    Navigator.pop(context);


                  },



                  child: Container(


                    padding:
                    const EdgeInsets.all(8),


                    decoration:
                    const BoxDecoration(

                      color:
                      Colors.red,

                      shape:
                      BoxShape.circle,

                    ),



                    child:
                    const Icon(

                      Icons.close,

                      color:
                      Colors.white,

                    ),


                  ),

                ),


              ],

            ),



          ],


        ),

      ),

    );

  }







  Widget _buildBottomControls(
      LiveRoomController liveController,
      ) {


    return SafeArea(


      child: Padding(


        padding:
        const EdgeInsets.all(12),



        child: Column(


          mainAxisAlignment:
          MainAxisAlignment.end,



          children: [



            _buildChatBox(),




            const SizedBox(

              height: 10,

            ),




            Row(


              mainAxisAlignment:
              MainAxisAlignment.spaceAround,



              children: [



                _button(

                  Icons.mic,

                      (){

                    liveController.toggleMic();

                  },

                ),




                _button(

                  Icons.cameraswitch,

                      (){

                    liveController.switchCamera();

                  },

                ),





                _button(

                  Icons.favorite,

                      (){

                    liveController.sendLike();

                  },

                ),





                _button(

                  Icons.card_giftcard,

                      (){

                    _showGiftPanel();

                  },

                ),




                _button(

                  Icons.exit_to_app,

                      (){


                    liveController.leaveLive();


                    Navigator.pop(context);


                  },


                  color:
                  Colors.red,

                ),



              ],


            ),


          ],

        ),

      ),

    );

  }







  Widget _button(

      IconData icon,

      VoidCallback onTap,

      {

      Color color = Colors.white,

      }

      ){


    return GestureDetector(


      onTap: onTap,


      child: Container(


        height: 48,

        width: 48,


        decoration:
        const BoxDecoration(

          color:
          Colors.black54,

          shape:
          BoxShape.circle,

        ),



        child:
        Icon(

          icon,

          color:
          color,

        ),


      ),

    );

  }








  Widget _buildChatBox(){


    return Container(


      height: 120,


      padding:
      const EdgeInsets.all(8),



      decoration:
      BoxDecoration(

        color:
        Colors.black45,


        borderRadius:
        BorderRadius.circular(12),

      ),



      child: Column(


        children: [



          Expanded(


            child: ListView.builder(


              itemCount:
              controller.messages.length,



              itemBuilder:
                  (context,index){



                final msg =
                controller.messages[index];



                return Text(

                  "${msg.senderName}: ${msg.message}",


                  style:
                  const TextStyle(

                    color:
                    Colors.white,

                  ),

                );


              },

            ),

          ),




          Row(


            children: [



              Expanded(


                child: TextField(


                  controller:
                  controller.chatController,



                  style:
                  const TextStyle(

                    color:
                    Colors.white,

                  ),



                  decoration:
                  const InputDecoration(

                    hintText:
                    "Type message",


                    hintStyle:
                    TextStyle(

                      color:
                      Colors.white54,

                    ),

                  ),

                ),

              ),



              IconButton(


                onPressed: (){


                  controller.sendMessage();


                },


                icon:
                const Icon(

                  Icons.send,

                  color:
                  Colors.white,

                ),

              ),

            ],


          ),


        ],


      ),


    );


  }






  void _showGiftPanel(){


    controller.sendGift(

      giftId: "gift1",

      giftName: "Rose",

      diamonds: 10,

    );


  }


}