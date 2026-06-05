import 'package:flutter/material.dart';

/// Centraliza los colores y sombras de la aplicación
/// para los temas claro y oscuro.
class SpotlyColors {

  /// Color de fondo principal.
  static Color bg(bool dark) =>
      dark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC);

  /// Color de tarjetas y contenedores.
  static Color card(bool dark) =>
      dark ? const Color(0xFF1E293B).withOpacity(0.7) : Colors.white;

  /// Color de la barra de navegación.
  static Color nav(bool dark) =>
      dark ? const Color(0xFF0F172A) : Colors.white;

  /// Color de acento utilizado en botones y elementos destacados.
  static Color accent(bool dark) =>
      dark ? const Color(0xFF2DD4BF) : const Color(0xFF0891B2);

  /// Color principal para textos.
  static Color text(bool dark) =>
      dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);

  /// Color secundario para textos de apoyo o descripciones.
  static Color subText(bool dark) =>
      dark ? Colors.blueGrey[400]! : Colors.blueGrey[600]!;

  /// Sombra utilizada por tarjetas y componentes elevados.
  static List<BoxShadow> shadow(bool dark) => [
        BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.5 : 0.08),
          blurRadius: 30,
          offset: const Offset(0, 15),
        )
      ];
}