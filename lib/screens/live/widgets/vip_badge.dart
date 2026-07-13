import 'package:flutter/material.dart';

class VipBadge extends StatelessWidget {
  final int vipLevel;

  const VipBadge({
    super.key,
    required this.vipLevel,
  });

  @override
  Widget build(BuildContext context) {
    if (vipLevel <= 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [
            Color(0xffF9A825),
            Color(0xffF57F17),
          ],
        ),
      ),
      child: Text(
        "VIP $vipLevel",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}