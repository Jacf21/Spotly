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

    return Expanded(
      child: SpotlyInteractive(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ],
            ),

            /// 🔴 BADGE ROJO
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                right: 18,
                top: 6,
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