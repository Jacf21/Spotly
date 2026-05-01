import 'package:flutter/material.dart';
import '../../../../core/themes/spotly_colors.dart';

class PlaceProfileData {
  final String name;
  final String description;
  final int? categoriaId;       // INTEGER → id real de la tabla categorias
  final String categoriaNombre; // solo para mostrar en UI

  const PlaceProfileData({
    required this.name,
    this.description = '',
    this.categoriaId,
    this.categoriaNombre = '',
  });
}

// Mapeo exacto de tus categorías según el INSERT que hiciste
// Los IDs son SERIAL, así que respetan el orden de inserción (1-10)
class _Categoria {
  final int id;
  final String nombre;
  final String emoji;
  const _Categoria(this.id, this.nombre, this.emoji);
}

class PlaceProfileSheet extends StatefulWidget {
  final String initialName;
  final bool isDark;
  final void Function(PlaceProfileData data) onConfirm;

  const PlaceProfileSheet({
    super.key,
    required this.initialName,
    required this.isDark,
    required this.onConfirm,
  });

  static Future<PlaceProfileData?> show(
      BuildContext context, String initialName, bool isDark) {
    return showModalBottomSheet<PlaceProfileData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaceProfileSheet(
        initialName: initialName,
        isDark: isDark,     // 👈 usar el valor recibido
        onConfirm: (data) => Navigator.of(context).pop(data),
      ),
    );
  }

  @override
  State<PlaceProfileSheet> createState() => _PlaceProfileSheetState();
}

class _PlaceProfileSheetState extends State<PlaceProfileSheet> {
  static const List<_Categoria> _categorias = [
    _Categoria(1,  'Montaña',           '⛰'),
    _Categoria(2,  'Lago',              '💧'),
    _Categoria(3,  'Ciudad',            '🏙'),
    _Categoria(4,  'Sitio Arqueológico','🏛'),
    _Categoria(5,  'Parque Nacional',   '🌿'),
    _Categoria(6,  'Museo',             '🖼'),
    _Categoria(7,  'Aventura',          '🧗'),
    _Categoria(8,  'Gastronomía',       '🍽'),
    _Categoria(9,  'Salar',             '🧂'),
    _Categoria(10, 'Selva',             '🌳'),
  ];

  bool _fillMore = false;
  late String _name;
  String _description = '';
  _Categoria? _selectedCat;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.isDark;

    final card = SpotlyColors.card(dark);
    final textColor = SpotlyColors.text(dark);
    final subtitleColor = SpotlyColors.subText(dark);
    final accent = SpotlyColors.accent(dark);

    final fieldBg = dark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.shade100;

    return Material(
      color: card, // 👈 usa SpotlyColors.card(dark)
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HANDLE
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subtitleColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// TITLE
              Row(
                children: [
                  Icon(Icons.place_outlined, color: accent, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "Perfil del lugar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text(
                "Se creará automáticamente. Solo el nombre es obligatorio.",
                style: TextStyle(fontSize: 13, color: subtitleColor),
              ),

              const SizedBox(height: 20),

              /// INPUT NOMBRE
              _label("Nombre del lugar", textColor),
              const SizedBox(height: 6),

              TextFormField(
                initialValue: _name,
                onChanged: (v) => _name = v,
                style: TextStyle(color: textColor),
                decoration: _inputDeco("Ej: Cascada de Pairumani", fieldBg, dark),
              ),

              const SizedBox(height: 20),

              /// TOGGLE
              GestureDetector(
                onTap: () => setState(() => _fillMore = !_fillMore),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _fillMore
                        ? accent.withOpacity(0.12)
                        : fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _fillMore
                          ? accent.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedRotation(
                        turns: _fillMore ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: _fillMore ? accent : subtitleColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Agregar más datos (opcional)",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Descripción y categoría del lugar",
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// CAMPOS OPCIONALES
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: _fillMore
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),

                          _label("Descripción del lugar", textColor),
                          const SizedBox(height: 6),

                          TextFormField(
                            onChanged: (v) => _description = v,
                            maxLines: 3,
                            style: TextStyle(color: textColor),
                            decoration: _inputDeco(
                              "Cuéntanos sobre este lugar...",
                              fieldBg,
                              dark,
                            ),
                          ),

                          const SizedBox(height: 18),

                          _label("Categoría", textColor),
                          const SizedBox(height: 10),

                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 3.2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _categorias.length,
                            itemBuilder: (_, i) {
                              final cat = _categorias[i];
                              final sel = _selectedCat?.id == cat.id;

                              return GestureDetector(
                                onTap: () => setState(() =>
                                    _selectedCat = sel ? null : cat),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? accent
                                        : fieldBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  child: Row(
                                    children: [
                                      Text(cat.emoji,
                                          style: const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          cat.nombre,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: sel
                                                ? Colors.black
                                                : textColor,
                                            fontWeight: sel
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 28),

              /// BOTÓN
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => widget.onConfirm(
                    PlaceProfileData(
                      name: _name.trim().isEmpty
                          ? widget.initialName
                          : _name.trim(),
                      description: _description,
                      categoriaId: _selectedCat?.id,
                      categoriaNombre: _selectedCat?.nombre ?? '',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Confirmar y publicar",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }

  Widget _label(String text, Color color) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: color.withOpacity(0.6),
        ),
      );

  InputDecoration _inputDeco(String hint, Color bg, bool dark) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: dark ? Colors.white38 : Colors.grey),
        filled: true,
        fillColor: bg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}