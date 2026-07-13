import 'package:flutter/material.dart';

class LiveVideoView extends StatelessWidget {
  final Widget? child;

  const LiveVideoView({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
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
    );
  }
}