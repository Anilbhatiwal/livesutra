class PostModel {
  final String postId;
  final String userId;
  final String userName;
  final String userImage;
  final String imageUrl;
  final String caption;
  final DateTime createdAt;
  final int likes;

  PostModel({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.imageUrl,
    required this.caption,
    required this.createdAt,
    required this.likes,
  });

  factory PostModel.fromMap(Map<String, dynamic> map, String id) {
    return PostModel(
      postId: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      likes: map['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'imageUrl': imageUrl,
      'caption': caption,
      'createdAt': createdAt,
      'likes': likes,
    };
  }
}