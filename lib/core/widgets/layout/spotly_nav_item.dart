import 'package:flutter/material.dart';
import '../../themes/spotly_colors.dart';
import '../interactive/spotly_interactive.dart';

class SpotlyNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool dark;
  final VoidCallback onTap;

  const SpotlyNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        active ? SpotlyColors.accent(dark) : SpotlyColors.subText(dark);

    return Expanded(
      child: SpotlyInteractive(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, color: color),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}