import 'package:flutter/material.dart';
import '../../themes/spotly_colors.dart';

class SpotlyLogo extends StatelessWidget {
  final bool dark;
  final double size;

  const SpotlyLogo({super.key, required this.dark, this.size = 26});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w900,
        ),
        children: [
          TextSpan(
              text: 'SPOT',
              style: TextStyle(color: SpotlyColors.accent(dark))),
          TextSpan(
              text: 'LY',
              style: TextStyle(color: SpotlyColors.text(dark))),
        ],
      ),
    );
  }
}