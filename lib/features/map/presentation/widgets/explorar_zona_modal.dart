import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import '../../data/models/map_lugar_model.dart';

class ExplorarZonaModal extends StatelessWidget {
  final List<MapLugarModel> lugares;
  final bool dark;

  const ExplorarZonaModal({
    super.key,
    required this.lugares,
    required this.dark,
  });

  static void show(
    BuildContext context, {
    required List<MapLugarModel> lugares,
    required bool dark,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExplorarZonaModal(lugares: lugares, dark: dark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = SpotlyColors.bg(dark);
    final card = SpotlyColors.card(dark);
    final accent = SpotlyColors.accent(dark);
    final text = SpotlyColors.text(dark);
    final sub = SpotlyColors.subText(dark);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Handle ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sub.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Header ────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.mapPin,
                          size: 18, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lugares en esta zona',
                          style: TextStyle(
                            color: text,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${lugares.length} lugar${lugares.length != 1 ? 'es' : ''} encontrado${lugares.length != 1 ? 's' : ''}',
                          style:
                              TextStyle(color: sub, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(LucideIcons.x, color: sub, size: 20),
                    ),
                  ],
                ),
              ),

              Divider(color: sub.withOpacity(0.15), height: 1),

              // ── Lista ─────────────────────────────────────────
              Expanded(
                child: lugares.isEmpty
                    ? _buildEmpty(sub, text)
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: lugares.length,
                        itemBuilder: (_, i) => _LugarCard(
                          lugar: lugares[i],
                          dark: dark,
                          card: card,
                          accent: accent,
                          text: text,
                          sub: sub,
                          onTap: () {
                            Navigator.of(context).pop();
                            context.push('/lugar/${lugares[i].id}');
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(Color sub, Color text) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 48, color: sub),
            const SizedBox(height: 16),
            Text(
              'Sin lugares en esta zona',
              style: TextStyle(
                  color: text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Mueve el mapa para explorar otras áreas',
              style: TextStyle(color: sub, fontSize: 13),
            ),
          ],
        ),
      );
}

// ── Tarjeta individual ────────────────────────────────────────────────────────
class _LugarCard extends StatelessWidget {
  final MapLugarModel lugar;
  final bool dark;
  final Color card, accent, text, sub;
  final VoidCallback onTap;

  const _LugarCard({
    required this.lugar,
    required this.dark,
    required this.card,
    required this.accent,
    required this.text,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: SpotlyColors.shadow(dark),
        ),
        child: Row(
          children: [
            // Foto
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: SizedBox(
                width: 90,
                height: 90,
                child: lugar.fotoPortadaUrl != null
                    ? CachedNetworkImage(
                        imageUrl: lugar.fotoPortadaUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: accent.withOpacity(0.1),
                          child: Icon(LucideIcons.image,
                              color: sub, size: 24),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: accent.withOpacity(0.1),
                          child: Icon(LucideIcons.mapPin,
                              color: accent, size: 24),
                        ),
                      )
                    : Container(
                        color: accent.withOpacity(0.1),
                        child: Icon(LucideIcons.mapPin,
                            color: accent, size: 28),
                      ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lugar.esVerificado)
                          Icon(Icons.verified,
                              size: 14, color: accent),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(LucideIcons.tag, size: 11, color: sub),
                      const SizedBox(width: 3),
                      Text(
                        lugar.categoria,
                        style: TextStyle(color: sub, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.mapPin, size: 11, color: sub),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          lugar.departamento,
                          style: TextStyle(color: sub, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ]),
                    if (lugar.resumen != null || lugar.descripcion != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        lugar.resumen ?? lugar.descripcion ?? '',
                        style: TextStyle(color: sub, fontSize: 12, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(LucideIcons.chevronRight, size: 16, color: sub),
            ),
          ],
        ),
      ),
    );
  }
}