class LiveModel {
  final String liveId;
  final String streamId;

  final String hostId;
  final String hostName;
  final String hostImage;

  final String title;
  final String category;
  final String thumbnail;

  final bool isLive;

  final int viewers;
  final int likes;
  final int diamonds;

  final DateTime startedAt;
  final DateTime createdAt;

  LiveModel({
    required this.liveId,
    required this.streamId,

    required this.hostId,
    required this.hostName,
    required this.hostImage,

    required this.title,
    required this.category,
    required this.thumbnail,

    required this.isLive,

    required this.viewers,
    required this.likes,
    required this.diamonds,

    required this.startedAt,
    required this.createdAt,
  });


  Map<String, dynamic> toMap() {
    return {
      "liveId": liveId,
      "streamId": streamId,

      "hostId": hostId,
      "hostName": hostName,
      "hostImage": hostImage,

      "title": title,
      "category": category,
      "thumbnail": thumbnail,

      "isLive": isLive,

      "viewers": viewers,
      "likes": likes,
      "diamonds": diamonds,

      "startedAt": startedAt.millisecondsSinceEpoch,
      "createdAt": createdAt.millisecondsSinceEpoch,
    };
  }
    factory LiveModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return LiveModel(
      liveId: map["liveId"] ?? "",
      streamId: map["streamId"] ?? "",

      hostId: map["hostId"] ?? "",
      hostName: map["hostName"] ?? "",
      hostImage: map["hostImage"] ?? "",

      title: map["title"] ?? "",
      category: map["category"] ?? "",
      thumbnail: map["thumbnail"] ?? "",

      isLive: map["isLive"] ?? false,

      viewers: map["viewers"] ?? 0,
      likes: map["likes"] ?? 0,
      diamonds: map["diamonds"] ?? 0,

      startedAt: DateTime.fromMillisecondsSinceEpoch(
        map["startedAt"] ?? 0,
      ),

      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map["createdAt"] ?? 0,
      ),
    );
  }


  LiveModel copyWith({
    String? liveId,
    String? streamId,

    String? hostId,
    String? hostName,
    String? hostImage,

    String? title,
    String? category,
    String? thumbnail,

    bool? isLive,

    int? viewers,
    int? likes,
    int? diamonds,

    DateTime? startedAt,
    DateTime? createdAt,
  }) {
    return LiveModel(
      liveId: liveId ?? this.liveId,
      streamId: streamId ?? this.streamId,

      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostImage: hostImage ?? this.hostImage,

      title: title ?? this.title,
      category: category ?? this.category,
      thumbnail: thumbnail ?? this.thumbnail,

      isLive: isLive ?? this.isLive,

      viewers: viewers ?? this.viewers,
      likes: likes ?? this.likes,
      diamonds: diamonds ?? this.diamonds,

      startedAt: startedAt ?? this.startedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}