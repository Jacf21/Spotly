import 'package:flutter/material.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import '../../data/models/lugar_cercano_model.dart';

/// Resultado de la selección:
/// - lugarId != null → usuario eligió un existente
/// - lugarId == null → usuario quiere crear uno nuevo
class NearbyPlaceResult {
  final int? lugarId;
  final String? nombreLugar;
  const NearbyPlaceResult({this.lugarId, this.nombreLugar});
}

class NearbyPlaceSelector extends StatelessWidget {
  final List<LugarCercanoModel> lugares;
  final bool isDark;
  final void Function(NearbyPlaceResult result) onSelected;

  const NearbyPlaceSelector({
    super.key,
    required this.lugares,
    required this.isDark,
    required this.onSelected,
  });

  static Future<NearbyPlaceResult?> show(
    BuildContext context, {
    required List<LugarCercanoModel> lugares,
    required bool isDark,
  }) {
    return showModalBottomSheet<NearbyPlaceResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NearbyPlaceSelector(
        lugares: lugares,
        isDark: isDark,
        onSelected: (r) => Navigator.of(context).pop(r),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = SpotlyColors.card(isDark);
    final textColor = SpotlyColors.text(isDark);
    final subColor = SpotlyColors.subText(isDark);
    final accent = SpotlyColors.accent(isDark);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: subColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Título
          Row(children: [
            Icon(Icons.place, color: accent, size: 22),
            const SizedBox(width: 8),
            Text("Lugares cercanos encontrados",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ]),
          const SizedBox(height: 6),
          Text(
            "¿Tu publicación pertenece a alguno de estos lugares?",
            style: TextStyle(fontSize: 13, color: subColor),
          ),
          const SizedBox(height: 16),

          // Lista de lugares cercanos
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lugares.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final l = lugares[i];
              return GestureDetector(
                onTap: () => onSelected(
                    NearbyPlaceResult(lugarId: l.id, nombreLugar: l.nombre)),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: accent.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    // Foto o placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: l.fotoUrl != null
                          ? Image.network(l.fotoUrl!,
                              width: 52, height: 52,
                              fit: BoxFit.cover)
                          : Container(
                              width: 52, height: 52,
                              color: accent.withOpacity(0.15),
                              child: Icon(Icons.place,
                                  color: accent, size: 28)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.nombre,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                  fontSize: 14)),
                          const SizedBox(height: 3),
                          Row(children: [
                            if (l.categoria.isNotEmpty) ...[
                              Text(l.categoria,
                                  style: TextStyle(
                                      fontSize: 12, color: subColor)),
                              Text("  •  ",
                                  style: TextStyle(color: subColor)),
                            ],
                            Text(
                              "${l.distanciaM.toStringAsFixed(0)} m",
                              style: TextStyle(
                                  fontSize: 12, color: accent),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: subColor),
                  ]),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Opción crear nuevo
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () => onSelected(
                  const NearbyPlaceResult(lugarId: null)),
              icon: Icon(Icons.add, color: accent),
              label: Text("Crear como nuevo lugar",
                  style: TextStyle(color: accent)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: accent.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}