import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../themes/spotly_colors.dart';
import '../interactive/spotly_interactive.dart';

class SpotlyAddButton extends StatelessWidget {
  final bool dark;
  final VoidCallback onTap;

  const SpotlyAddButton({
    super.key,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      alignment: Alignment.center,
      child: SpotlyInteractive(
        onTap: onTap,
        scaleOnTap: 0.85,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SpotlyColors.accent(dark),
                SpotlyColors.accent(dark).withOpacity(0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SpotlyColors.accent(dark).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.plus,
            color: Colors.white,
            size: 28,
          ),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(end: -4, duration: 2.seconds),
    );
  }
}