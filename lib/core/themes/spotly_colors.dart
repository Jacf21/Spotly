import 'package:flutter/material.dart';

class SpotlyColors {
  static Color bg(bool dark) =>
      dark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC);

  static Color card(bool dark) =>
      dark ? const Color(0xFF1E293B).withOpacity(0.7) : Colors.white;

  static Color nav(bool dark) =>
      dark ? const Color(0xFF0F172A) : Colors.white;

  static Color accent(bool dark) =>
      dark ? const Color(0xFF2DD4BF) : const Color(0xFF0891B2);

  static Color text(bool dark) =>
      dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);

  static Color subText(bool dark) =>
      dark ? Colors.blueGrey[400]! : Colors.blueGrey[600]!;

  static List<BoxShadow> shadow(bool dark) => [
        BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.5 : 0.08),
          blurRadius: 30,
          offset: const Offset(0, 15),
        )
      ];
}