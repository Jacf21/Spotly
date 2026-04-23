import 'package:flutter/material.dart';
import '../../themes/spotly_colors.dart';
import '../interactive/spotly_interactive.dart';

class SpotlyNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool dark;
  final VoidCallback onTap;
  final int? badgeCount;

  const SpotlyNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.dark,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        active ? SpotlyColors.accent(dark) : SpotlyColors.subText(dark);

    return SpotlyInteractive(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          top: 12,
          bottom: 4,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min, // ✅ solo ocupa lo necesario
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 3),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: color, fontSize: 9),
                ),
              ],
            ),

            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                top: -4,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badgeCount! > 9 ? "9+" : "$badgeCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}