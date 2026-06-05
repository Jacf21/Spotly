import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../themes/spotly_config.dart';

/// Widget reutilizable que añade una animación de presión
/// y retroalimentación háptica al tocar cualquier componente.
class SpotlyInteractive extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  /// Escala aplicada mientras el usuario mantiene presionado el widget.
  final double scaleOnTap;

  const SpotlyInteractive({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleOnTap = 0.92,
  });

  @override
  State<SpotlyInteractive> createState() => _SpotlyInteractiveState();
}

class _SpotlyInteractiveState extends State<SpotlyInteractive> {
  // Controla el estado visual de presión del componente.
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),

      // Ejecuta la acción y genera una vibración breve.
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },

      child: AnimatedScale(
        scale: _isPressed ? widget.scaleOnTap : 1.0,
        duration: SpotlyConfig.animShort,
        curve: SpotlyConfig.curve,
        child: widget.child,
      ),
    );
  }
}