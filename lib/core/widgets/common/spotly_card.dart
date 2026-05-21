import 'package:flutter/material.dart';
import '../../themes/spotly_colors.dart';

class SpotlyCrystalCard extends StatelessWidget {
  final Widget child;
  final bool dark;
  final EdgeInsets padding;

  const SpotlyCrystalCard({
    super.key,
    required this.child,
    required this.dark,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: SpotlyColors.card(dark),
        borderRadius: BorderRadius.circular(28),

        /// ✨ efecto glass + borde sutil
        border: Border.all(
          color: dark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
        ),

        /// 🌑 sombra adaptativa
        boxShadow: SpotlyColors.shadow(dark),
      ),
      child: child,
    );
  }
}