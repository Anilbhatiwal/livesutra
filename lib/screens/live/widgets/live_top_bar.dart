import 'package:flutter/material.dart';

class LiveTopBar extends StatelessWidget {
  final String hostName;
  final String hostImage;
  final int viewerCount;
  final VoidCallback onClose;

  const LiveTopBar({
    super.key,
    required this.hostName,
    required this.hostImage,
    required this.viewerCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 10,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 23,
              backgroundImage: hostImage.isNotEmpty
                  ? NetworkImage(hostImage)
                  : null,
              child: hostImage.isEmpty
                  ? const Icon(Icons.person)
                  : null,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    hostName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    "$viewerCount Watching",
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius:
                    BorderRadius.circular(25),
              ),
              child: const Text(
                "🔴 LIVE",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 8),

            IconButton(
              onPressed: onClose,
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}