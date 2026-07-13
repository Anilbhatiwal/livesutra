class ChatModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String message;
  final String messageType;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.message,
    required this.messageType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "senderId": senderId,
      "senderName": senderName,
      "senderImage": senderImage,
      "message": message,
      "messageType": messageType,
      "createdAt": createdAt.millisecondsSinceEpoch,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map["id"] ?? "",
      senderId: map["senderId"] ?? "",
      senderName: map["senderName"] ?? "",
      senderImage: map["senderImage"] ?? "",
      message: map["message"] ?? "",
      messageType: map["messageType"] ?? "text",
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map["createdAt"] ?? 0,
      ),
    );
  }
}