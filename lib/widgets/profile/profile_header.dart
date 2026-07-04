import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String username;
  final String bio;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.username,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "@$username",
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          bio,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}