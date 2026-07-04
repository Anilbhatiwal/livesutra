class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String bio;
  final String country;
  final String gender;
  final int age;
  final int followers;
  final int following;
  final int coins;
  final int diamonds;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.bio,
    required this.country,
    required this.gender,
    required this.age,
    required this.followers,
    required this.following,
    required this.coins,
    required this.diamonds,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      bio: map['bio'] ?? '',
      country: map['country'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      coins: map['coins'] ?? 0,
      diamonds: map['diamonds'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'country': country,
      'gender': gender,
      'age': age,
      'followers': followers,
      'following': following,
      'coins': coins,
      'diamonds': diamonds,
    };
  }
}