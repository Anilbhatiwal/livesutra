import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/live_room_controller.dart';

class LiveVideoView extends StatelessWidget {
  final Widget? child;

  const LiveVideoView({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LiveRoomController>();

return Positioned.fill(
  
  child: Stack(
    children: [
    Positioned(
  top: 50,
  right: 16,
  child: Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 6,
    ),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
      Icon(
  Icons.network_check,
  color: controller.networkQuality <= 1
      ? Colors.green
      : controller.networkQuality == 2
          ? Colors.orange
          : Colors.red,
  size: 18,
),
        const SizedBox(width: 6),
        Text(
          "Net ${controller.networkQuality}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  ),
),
      Container(
        color: Colors.black,
        child: child ??
            const Center(
              child: Text(
                "ZEGO LIVE VIDEO",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      ),

      if (!controller.connected)
        Container(
          color: Colors.black54,
          child: Center(
            child: Text(
              controller.connectionText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

      if (controller.reconnecting)
        const Center(
          child: CircularProgressIndicator(),
        ),
    ],
  ),
);
  }
}