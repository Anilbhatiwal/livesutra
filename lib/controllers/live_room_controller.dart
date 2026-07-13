import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import '../models/live_model.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../services/zego_service.dart';


class LiveRoomController extends ChangeNotifier {


  LiveRoomController({

    required this.live,

    required this.userId,

    required this.userName,

    required this.isHost,

  });



  final LiveModel live;


  final String userId;

  final String userName;


  final bool isHost;



  final ChatService _chatService =
      ChatService();



  final TextEditingController chatController =
      TextEditingController();




  bool _isInitialized = false;


  bool get isInitialized =>
      _isInitialized;




  bool _micOn = true;


  bool get micOn =>
      _micOn;




  bool _cameraOn = true;


  bool get cameraOn =>
      _cameraOn;




  bool _speakerOn = true;


  bool get speakerOn =>
      _speakerOn;




  int _viewerCount = 0;


  int get viewerCount =>
      _viewerCount;



  int _likes = 0;


  int get likes =>
      _likes;




  final List<ChatModel> _messages = [];


  List<ChatModel> get messages =>
      _messages;



  StreamSubscription?
      _liveSubscription;



  StreamSubscription?
      _giftSubscription;



  Future<void> initialize() async {


    if (_isInitialized) return;

    await ZegoService.init();

  debugPrint("ZEGO Engine Initialized");


    await ZegoService.loginRoom(

      roomID: live.liveId,

      userID: userId,

      userName: userName,

    );


    debugPrint("ZEGO Room Login Success");

    if (isHost) {


      await ZegoService.startPreview();



      await ZegoService.startPublishing(

        streamID: live.streamId,

      );



      await _chatService.updateLiveStatus(

        liveId: live.liveId,

        isLive: true,

      );



    } else {


      await ZegoService.startPlaying(

        streamID: live.streamId,

      );



      await _chatService.increaseViewer(

        liveId: live.liveId,

      );


    }

    _isInitialized = true;


    _listenLiveData();

    notifyListeners();

  }
    void _listenLiveData() {


    _liveSubscription?.cancel();


    _liveSubscription =
        _chatService
            .getLiveRoom(
              live.liveId,
            )
            .listen((snapshot) {


      final data =
          snapshot.data();



      if (data == null) return;



      _likes =
          data["likes"] ?? 0;



      _viewerCount =
          data["viewers"] ?? 0;



      notifyListeners();


    });

  }





  Future<void> toggleMic() async {


    _micOn = !_micOn;



    await ZegoService.enableMicrophone(

      _micOn,

    );



    notifyListeners();

  }





  Future<void> toggleCamera() async {


    _cameraOn = !_cameraOn;



    await ZegoService.enableCamera(

      _cameraOn,

    );



    notifyListeners();

  }





  Future<void> switchCamera() async {


    await ZegoService.switchCamera();


  }





  Future<void> toggleSpeaker() async {


    _speakerOn = !_speakerOn;



    await ZegoService.enableSpeaker(

      _speakerOn,

    );


    notifyListeners();

  }





  Future<void> sendLike() async {


    await _chatService.sendLike(

      liveId: live.liveId,

    );


  }





  Future<void> sendMessage() async {


    final text =
        chatController.text.trim();



    if (text.isEmpty) return;




    final chat = ChatModel(
  id: DateTime.now()
      .millisecondsSinceEpoch
      .toString(),

  senderId: userId,

  senderName: userName,

  senderImage: "",

  message: "",

  messageType: "text",

  createdAt: DateTime.now(),
);



    await _chatService.sendMessage(

      roomId: live.liveId,

      chat: chat,

    );



    _messages.add(chat);



    chatController.clear();



    notifyListeners();

  }





  Future<void> sendGift({

    required String giftId,

    required String giftName,

    required int diamonds,

  }) async {



    await _chatService.sendGift(

      liveId: live.liveId,

      senderId: userId,

      senderName: userName,

      giftId: giftId,

      giftName: giftName,

      diamonds: diamonds,

    );


  }





  Future<void> endLive() async {



    if (!isHost) return;




    await ZegoService.stopPublishing();




    await ZegoService.logoutRoom(

      live.liveId,

    );




    await _chatService.updateLiveStatus(

      liveId: live.liveId,

      isLive: false,

    );



    notifyListeners();


  }





  Future<void> leaveLive() async {



    if (isHost) {


      await endLive();


      return;

    }




    await ZegoService.stopPlaying(

      streamID: live.streamId,

    );



    await ZegoService.logoutRoom(

      live.liveId,

    );



    await _chatService.decreaseViewer(

      liveId: live.liveId,

    );



    notifyListeners();


  }





  void registerZegoCallbacks() {



    ZegoExpressEngine.onRoomUserUpdate =

    (

      String roomID,

      ZegoUpdateType updateType,

      List<ZegoUser> userList,

    ) {



      if(roomID != live.liveId) return;




      if(updateType == ZegoUpdateType.Add){


        _viewerCount += userList.length;


      } else {


        _viewerCount -= userList.length;



        if(_viewerCount < 0){

          _viewerCount = 0;

        }

      }




      notifyListeners();


    };





    ZegoExpressEngine.onPlayerStateUpdate =

    (

      String streamID,

      ZegoPlayerState state,

      int errorCode,

      Map<String,dynamic> data,

    ){


      notifyListeners();


    };





    ZegoExpressEngine.onPublisherStateUpdate =

    (

      String streamID,

      ZegoPublisherState state,

      int errorCode,

      Map<String,dynamic> data,

    ){


      notifyListeners();


    };


  }





  @override
  void dispose() {


    _liveSubscription?.cancel();


    _giftSubscription?.cancel();



    chatController.dispose();




    ZegoExpressEngine.onRoomUserUpdate = null;


    ZegoExpressEngine.onPlayerStateUpdate = null;


    ZegoExpressEngine.onPublisherStateUpdate = null;



    super.dispose();


  }


}