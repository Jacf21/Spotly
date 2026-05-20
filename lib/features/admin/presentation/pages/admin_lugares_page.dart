// features/admin/presentation/pages/admin_lugares_page.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';

import '../../data/datasources/lugares_datasource.dart';
import '../../data/models/admin_lugar_model.dart';
import '../../data/repositories/lugares_repository.dart';

class AdminLugaresPage extends StatefulWidget {
  const AdminLugaresPage({super.key});

  @override
  State<AdminLugaresPage> createState() => _AdminLugaresPageState();
}

class _AdminLugaresPageState extends State<AdminLugaresPage> {
  late final LugaresRepository _repo;

  List<AdminLugarModel> _lugares = [];
  List<AdminLugarModel> _filtrados = [];
  List<Map<String, dynamic>> _categorias = [];
  bool _loading = true;

  final _searchController = TextEditingController();
  String? _filtroDep;
  String? _filtroCat;

  @override
  void initState() {
    super.initState();
    _repo = LugaresRepository(
      LugaresDatasource(Supabase.instance.client),
    );
    _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    if (mounted) setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _repo.getLugares(),
        _repo.getCategorias(),
      ]);
      if (mounted) {
        setState(() {
          _lugares = results[0] as List<AdminLugarModel>;
          _categorias = results[1] as List<Map<String, dynamic>>;
          _aplicarFiltros();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _aplicarFiltros() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtrados = _lugares.where((l) {
        final matchQ = q.isEmpty ||
            l.nombre.toLowerCase().contains(q) ||
            (l.descripcion?.toLowerCase().contains(q) ?? false);
        final matchDep = _filtroDep == null || l.departamento == _filtroDep;
        final matchCat = _filtroCat == null || l.categoria == _filtroCat;
        return matchQ && matchDep && matchCat;
      }).toList();
    });
  }

  // ── Modal de edición ──────────────────────────────────────────────────────

  void _abrirEdicion(AdminLugarModel lugar, bool dark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditarLugarSheet(
        lugar: lugar,
        categorias: _categorias,
        dark: dark,
        repo: _repo,
        onGuardado: _loadAll,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    // Departamentos únicos para el filtro
    final deptos = _lugares.map((l) => l.departamento)
        .where((d) => d.isNotEmpty).toSet().toList()..sort();
    final cats = _lugares.map((l) => l.categoria)
        .where((c) => c.isNotEmpty).toSet().toList()..sort();

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('Lugares',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: SpotlyColors.text(dark))),
                  ),
                  if (!_loading)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: SpotlyColors.accent(dark).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${_lugares.length} total',
                          style: TextStyle(
                              color: SpotlyColors.accent(dark),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                ]),
                const SizedBox(height: 14),

                // Buscador
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: SpotlyColors.card(dark),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: SpotlyColors.shadow(dark),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 12),
                    Icon(LucideIcons.search,
                        size: 16, color: SpotlyColors.subText(dark)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _aplicarFiltros(),
                        style: TextStyle(
                            color: SpotlyColors.text(dark), fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Buscar lugar...',
                          hintStyle: TextStyle(
                              color: SpotlyColors.subText(dark), fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(LucideIcons.x,
                            size: 14, color: SpotlyColors.subText(dark)),
                        onPressed: () {
                          _searchController.clear();
                          _aplicarFiltros();
                        },
                      ),
                  ]),
                ),
                const SizedBox(height: 10),

                // Filtros chip
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    // Departamento
                    _FilterChip(
                      label: _filtroDep ?? 'Departamento',
                      active: _filtroDep != null,
                      dark: dark,
                      onTap: () => _showFilterSheet(
                        title: 'Departamento',
                        options: deptos,
                        selected: _filtroDep,
                        dark: dark,
                        onSelect: (v) =>
                            setState(() { _filtroDep = v; _aplicarFiltros(); }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Categoría
                    _FilterChip(
                      label: _filtroCat ?? 'Categoría',
                      active: _filtroCat != null,
                      dark: dark,
                      onTap: () => _showFilterSheet(
                        title: 'Categoría',
                        options: cats,
                        selected: _filtroCat,
                        dark: dark,
                        onSelect: (v) =>
                            setState(() { _filtroCat = v; _aplicarFiltros(); }),
                      ),
                    ),
                    if (_filtroDep != null || _filtroCat != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() {
                          _filtroDep = null;
                          _filtroCat = null;
                          _aplicarFiltros();
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Limpiar',
                              style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ]),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── Lista ──────────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.mapPin,
                                size: 48,
                                color: SpotlyColors.subText(dark)),
                            const SizedBox(height: 12),
                            Text('Sin resultados',
                                style: TextStyle(
                                    color: SpotlyColors.subText(dark))),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAll,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _filtrados.length,
                          itemBuilder: (_, i) => _LugarCard(
                            lugar: _filtrados[i],
                            dark: dark,
                            onTap: () => _abrirEdicion(_filtrados[i], dark),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet({
    required String title,
    required List<String> options,
    required String? selected,
    required bool dark,
    required void Function(String?) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SpotlyColors.card(dark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: SpotlyColors.subText(dark).withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title,
                style: TextStyle(
                    color: SpotlyColors.text(dark),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ),
          // Opción "Todos"
          ListTile(
            title: Text('Todos',
                style: TextStyle(color: SpotlyColors.text(dark))),
            trailing: selected == null
                ? Icon(LucideIcons.check,
                    size: 16, color: SpotlyColors.accent(dark))
                : null,
            onTap: () {
              Navigator.pop(context);
              onSelect(null);
            },
          ),
          ...options.map((o) => ListTile(
                title: Text(o,
                    style: TextStyle(color: SpotlyColors.text(dark))),
                trailing: selected == o
                    ? Icon(LucideIcons.check,
                        size: 16, color: SpotlyColors.accent(dark))
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onSelect(o);
                },
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Tarjeta de lugar ──────────────────────────────────────────────────────────

class _LugarCard extends StatelessWidget {
  final AdminLugarModel lugar;
  final bool dark;
  final VoidCallback onTap;

  const _LugarCard({
    required this.lugar,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = SpotlyColors.accent(dark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: SpotlyColors.card(dark),
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
                    ? Image.network(
                        lugar.fotoPortadaUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: accent.withOpacity(0.1),
                          child: Icon(LucideIcons.mapPin,
                              color: accent, size: 24),
                        ),
                      )
                    : Container(
                        color: accent.withOpacity(0.1),
                        child:
                            Icon(LucideIcons.mapPin, color: accent, size: 28),
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
                    Text(lugar.nombre,
                        style: TextStyle(
                            color: SpotlyColors.text(dark),
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Text(
                      '${lugar.categoria} · ${lugar.departamento}',
                      style: TextStyle(
                          color: SpotlyColors.subText(dark), fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(LucideIcons.heart,
                          size: 11, color: SpotlyColors.subText(dark)),
                      const SizedBox(width: 3),
                      Text('${lugar.likeCount}',
                          style: TextStyle(
                              color: SpotlyColors.subText(dark),
                              fontSize: 11)),
                      const SizedBox(width: 10),
                      Icon(LucideIcons.image,
                          size: 11, color: SpotlyColors.subText(dark)),
                      const SizedBox(width: 3),
                      Text('${lugar.publicacionesCount} pub.',
                          style: TextStyle(
                              color: SpotlyColors.subText(dark),
                              fontSize: 11)),
                    ]),
                  ],
                ),
              ),
            ),

            // Flecha editar
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(LucideIcons.pencil,
                  size: 15, color: SpotlyColors.subText(dark)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chip de filtro ────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool dark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = SpotlyColors.accent(dark);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? accent.withOpacity(0.15) : SpotlyColors.card(dark),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? accent.withOpacity(0.4) : Colors.transparent),
          boxShadow: active ? null : SpotlyColors.shadow(dark),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: TextStyle(
                  color: active ? accent : SpotlyColors.subText(dark),
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w600 : FontWeight.normal)),
          const SizedBox(width: 4),
          Icon(LucideIcons.chevronDown,
              size: 12,
              color: active ? accent : SpotlyColors.subText(dark)),
        ]),
      ),
    );
  }
}

// ── Sheet de edición ──────────────────────────────────────────────────────────

class _EditarLugarSheet extends StatefulWidget {
  final AdminLugarModel lugar;
  final List<Map<String, dynamic>> categorias;
  final bool dark;
  final LugaresRepository repo;
  final VoidCallback onGuardado;

  const _EditarLugarSheet({
    required this.lugar,
    required this.categorias,
    required this.dark,
    required this.repo,
    required this.onGuardado,
  });

  @override
  State<_EditarLugarSheet> createState() => _EditarLugarSheetState();
}

class _EditarLugarSheetState extends State<_EditarLugarSheet> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descCtrl;
  int? _categoriaSeleccionada;
  bool _guardando = false;

  // Para el selector de foto
  List<Map<String, dynamic>> _imagenes = [];
  bool _loadingImagenes = false;
  String? _fotoSeleccionada;
  bool _mostrarFotos = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.lugar.nombre);
    _descCtrl = TextEditingController(text: widget.lugar.descripcion ?? '');
    _categoriaSeleccionada = widget.lugar.idCategoria;
    _fotoSeleccionada = widget.lugar.fotoPortadaUrl;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarImagenes() async {
    if (_loadingImagenes) return;
    setState(() { _loadingImagenes = true; _mostrarFotos = true; });
    try {
      final imgs = await widget.repo.getImagenesLugar(widget.lugar.id);
      if (mounted) setState(() { _imagenes = imgs; _loadingImagenes = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingImagenes = false);
    }
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty) return;
    setState(() => _guardando = true);
    try {
      await widget.repo.updateLugar(
        lugarId: widget.lugar.id,
        nombre: _nombreCtrl.text.trim(),
        descripcion: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        idCategoria: _categoriaSeleccionada,
      );
      // Si cambió la foto, actualiza también
      if (_fotoSeleccionada != widget.lugar.fotoPortadaUrl &&
          _fotoSeleccionada != null) {
        await widget.repo.updateFotoPortada(
          lugarId: widget.lugar.id,
          nuevaUrl: _fotoSeleccionada!,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
        widget.onGuardado();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final accent = SpotlyColors.accent(dark);
    final card = SpotlyColors.card(dark);
    final text = SpotlyColors.text(dark);
    final sub = SpotlyColors.subText(dark);

    return Container(
      decoration: BoxDecoration(
        color: SpotlyColors.bg(dark),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 16,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: sub.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Row(children: [
              Expanded(
                child: Text('Editar lugar',
                    style: TextStyle(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: Icon(LucideIcons.x, color: sub, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ]),
            const SizedBox(height: 20),

            // ── Foto de portada ──────────────────────────────
            Text('Foto de portada',
                style: TextStyle(
                    color: text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(children: [
              // Preview actual
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 72, height: 72,
                  child: _fotoSeleccionada != null
                      ? Image.network(_fotoSeleccionada!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: accent.withOpacity(0.1),
                            child: Icon(LucideIcons.imageOff,
                                color: sub, size: 24),
                          ))
                      : Container(
                          color: accent.withOpacity(0.1),
                          child:
                              Icon(LucideIcons.image, color: sub, size: 24),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _cargarImagenes,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: accent.withOpacity(0.3)),
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.image,
                              size: 16, color: accent),
                          const SizedBox(width: 8),
                          Text('Cambiar foto',
                              style: TextStyle(
                                  color: accent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ]),
                  ),
                ),
              ),
            ]),

            // Grid de imágenes del lugar
            if (_mostrarFotos) ...[
              const SizedBox(height: 12),
              if (_loadingImagenes)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ))
              else if (_imagenes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No hay imágenes subidas para este lugar.',
                    style: TextStyle(color: sub, fontSize: 12),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: _imagenes.length,
                  itemBuilder: (_, i) {
                    final img = _imagenes[i];
                    final url = img['url_recurso'] as String;
                    final isSelected = _fotoSeleccionada == url;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _fotoSeleccionada = url),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(url,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                    color: accent.withOpacity(0.1))),
                          ),
                          if (isSelected)
                            Container(
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: accent, width: 2),
                              ),
                              child: Center(
                                child: Icon(LucideIcons.check,
                                    color: Colors.white, size: 28),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
            ],

            const SizedBox(height: 20),

            // ── Nombre ───────────────────────────────────────
            Text('Nombre',
                style: TextStyle(
                    color: text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _nombreCtrl,
              style: TextStyle(color: text, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: card,
                hintText: 'Nombre del lugar',
                hintStyle: TextStyle(color: sub),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // ── Descripción ──────────────────────────────────
            Text('Descripción',
                style: TextStyle(
                    color: text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              style: TextStyle(color: text, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: card,
                hintText: 'Descripción del lugar...',
                hintStyle: TextStyle(color: sub),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),

            // ── Categoría ────────────────────────────────────
            Text('Categoría',
                style: TextStyle(
                    color: text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _categoriaSeleccionada,
                  isExpanded: true,
                  dropdownColor: card,
                  hint: Text('Seleccionar categoría',
                      style: TextStyle(color: sub, fontSize: 14)),
                  style: TextStyle(color: text, fontSize: 14),
                  items: widget.categorias.map((c) {
                    return DropdownMenuItem<int>(
                      value: (c['id_categoria'] as num).toInt(),
                      child: Text(c['nombre_categoria'] as String),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setState(() => _categoriaSeleccionada = v),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Botón guardar ────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white))
                    : const Text('Guardar cambios',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}