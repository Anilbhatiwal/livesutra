import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int followers;
  final int following;
  final int coins;
  final int diamonds;

  const ProfileStats({
    super.key,
    required this.followers,
    required this.following,
    required this.coins,
    required this.diamonds,
  });

  Widget buildItem(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Row(
          children: [
            buildItem("Followers", followers.toString()),
            buildItem("Following", following.toString()),
          ],
        ),

        const SizedBox(height: 25),

        Row(
          children: [
            buildItem("Coins", coins.toString()),
            buildItem("Diamonds", diamonds.toString()),
          ],
        ),
      ],
    );
  }
}