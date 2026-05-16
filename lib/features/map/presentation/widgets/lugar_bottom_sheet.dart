import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spotly/core/themes/spotly_colors.dart';

import '../../data/models/map_lugar_model.dart';

/// Bottom sheet compacto que aparece al tocar un marcador en el mapa.
/// Muestra la info básica del lugar y dos acciones:
///   • Ver detalle → navega a /lugar/:id
///   • Cómo llegar → traza la ruta (callback al MapPage)
class LugarBottomSheet extends StatelessWidget {
  final MapLugarModel lugar;
  final bool dark;
  final bool tieneUbicacion; // si es false, deshabilita "Cómo llegar"
  final VoidCallback onComoLlegar;

  const LugarBottomSheet({
    super.key,
    required this.lugar,
    required this.dark,
    required this.tieneUbicacion,
    required this.onComoLlegar,
  });

  @override
  Widget build(BuildContext context) {
    final bg = SpotlyColors.card(dark);
    final text = SpotlyColors.text(dark);
    final sub = SpotlyColors.subText(dark);
    final accent = SpotlyColors.accent(dark);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: SpotlyColors.shadow(dark),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: sub.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Foto + info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: lugar.fotoPortadaUrl != null
                      ? CachedNetworkImage(
                          imageUrl: lugar.fotoPortadaUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: accent.withOpacity(0.1),
                            child: Icon(LucideIcons.image, color: sub),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: accent.withOpacity(0.1),
                            child:
                                Icon(LucideIcons.mapPin, color: accent, size: 28),
                          ),
                        )
                      : Container(
                          color: accent.withOpacity(0.1),
                          child:
                              Icon(LucideIcons.mapPin, color: accent, size: 28),
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lugar.nombre,
                            style: TextStyle(
                              color: text,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lugar.esVerificado)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.verified, size: 16, color: accent),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(LucideIcons.tag, size: 12, color: sub),
                      const SizedBox(width: 4),
                      Text(lugar.categoria,
                          style: TextStyle(color: sub, fontSize: 12)),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.mapPin, size: 12, color: sub),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(lugar.departamento,
                            style: TextStyle(color: sub, fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ]),
                    if (lugar.resumen != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        lugar.resumen!,
                        style:
                            TextStyle(color: sub, fontSize: 12, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              // Ver detalle
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/lugar/${lugar.id}');
                  },
                  icon: Icon(LucideIcons.info, size: 16, color: accent),
                  label:
                      Text('Ver detalle', style: TextStyle(color: accent)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accent.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Cómo llegar
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: tieneUbicacion ? onComoLlegar : null,
                  icon: const Icon(LucideIcons.navigation, size: 16,
                      color: Colors.white),
                  label: const Text('Cómo llegar',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    disabledBackgroundColor: accent.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),

          if (!tieneUbicacion) ...[
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Activa el GPS para obtener direcciones',
                style: TextStyle(color: sub, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}