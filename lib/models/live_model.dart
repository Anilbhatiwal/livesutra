class LiveModel {
  final String liveId;
  final String hostId;
  final String hostName;
  final String hostImage;
  final bool isLive;
  final int viewers;
  final DateTime startedAt;

  LiveModel({
    required this.liveId,
    required this.hostId,
    required this.hostName,
    required this.hostImage,
    required this.isLive,
    required this.viewers,
    required this.startedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "liveId": liveId,
      "hostId": hostId,
      "hostName": hostName,
      "hostImage": hostImage,
      "isLive": isLive,
      "viewers": viewers,
      "startedAt": startedAt.millisecondsSinceEpoch,
    };
  }

  factory LiveModel.fromMap(Map<String, dynamic> map) {
    return LiveModel(
      liveId: map["liveId"] ?? "",
      hostId: map["hostId"] ?? "",
      hostName: map["hostName"] ?? "",
      hostImage: map["hostImage"] ?? "",
      isLive: map["isLive"] ?? false,
      viewers: map["viewers"] ?? 0,
      startedAt: DateTime.fromMillisecondsSinceEpoch(
        map["startedAt"] ?? 0,
      ),
    );
  }
}