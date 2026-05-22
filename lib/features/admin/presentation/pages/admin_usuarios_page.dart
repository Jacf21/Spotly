import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';

import '../../data/datasources/usuarios_datasource.dart';
import '../../data/models/admin_usuario_model.dart';
import '../../data/repositories/usuarios_repository.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {
  late final UsuariosRepository _repo;

  List<AdminUsuarioModel> _usuarios = [];
  List<AdminUsuarioModel> _filtrados = [];
  bool _loading = true;

  final _searchController = TextEditingController();
  String? _filtroRol;
  bool? _filtroActivo;

  @override
  void initState() {
    super.initState();
    _repo = UsuariosRepository(UsuariosDatasource(Supabase.instance.client));
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
      final data = await _repo.getUsuarios();
      if (mounted) {
        setState(() {
          _usuarios = data;
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
      _filtrados = _usuarios.where((u) {
        final matchQ = q.isEmpty ||
            u.nombreCompleto.toLowerCase().contains(q) ||
            (u.nombreUsuario?.toLowerCase().contains(q) ?? false) ||
            (u.email?.toLowerCase().contains(q) ?? false);
        final matchRol = _filtroRol == null || u.rol == _filtroRol;
        final matchActivo = _filtroActivo == null || u.esActivo == _filtroActivo;
        return matchQ && matchRol && matchActivo;
      }).toList();
    });
  }

  int get _totalActivos => _usuarios.where((u) => u.esActivo).length;
  int get _totalBaneados => _usuarios.where((u) => !u.esActivo).length;
  int get _totalConReportes => _usuarios.where((u) => u.reportesPendientes > 0).length;

  void _abrirDetalle(AdminUsuarioModel usuario, bool dark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UsuarioDetalleSheet(
        usuario: usuario,
        dark: dark,
        repo: _repo,
        onActualizado: _loadAll,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text('Usuarios',
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
                      child: Text('${_usuarios.length} total',
                          style: TextStyle(
                              color: SpotlyColors.accent(dark),
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                ]),
                const SizedBox(height: 14),
                if (!_loading)
                  Row(children: [
                    _StatChip(label: 'Activos', value: '$_totalActivos',
                        color: Colors.green, dark: dark),
                    const SizedBox(width: 8),
                    _StatChip(label: 'Baneados', value: '$_totalBaneados',
                        color: Colors.redAccent, dark: dark),
                    const SizedBox(width: 8),
                    _StatChip(label: 'Reportados', value: '$_totalConReportes',
                        color: const Color(0xFFF59E0B), dark: dark),
                  ]),
                const SizedBox(height: 14),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: SpotlyColors.card(dark),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: SpotlyColors.shadow(dark),
                  ),
                  child: Row(children: [
                    const SizedBox(width: 12),
                    Icon(LucideIcons.search, size: 16,
                        color: SpotlyColors.subText(dark)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => _aplicarFiltros(),
                        style: TextStyle(
                            color: SpotlyColors.text(dark), fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre, usuario o email...',
                          hintStyle: TextStyle(
                              color: SpotlyColors.subText(dark), fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(LucideIcons.x, size: 14,
                            color: SpotlyColors.subText(dark)),
                        onPressed: () {
                          _searchController.clear();
                          _aplicarFiltros();
                        },
                      ),
                  ]),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _FiltroChip(label: _filtroRol ?? 'Rol',
                        active: _filtroRol != null, dark: dark,
                        onTap: () => _showRolSheet(dark)),
                    const SizedBox(width: 8),
                    _FiltroChip(
                      label: _filtroActivo == null ? 'Estado'
                          : _filtroActivo! ? 'Activos' : 'Baneados',
                      active: _filtroActivo != null, dark: dark,
                      onTap: () => _showEstadoSheet(dark),
                    ),
                    if (_filtroRol != null || _filtroActivo != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() {
                          _filtroRol = null;
                          _filtroActivo = null;
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
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.users, size: 48,
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
                          itemBuilder: (_, i) => _UsuarioCard(
                            usuario: _filtrados[i],
                            dark: dark,
                            onTap: () => _abrirDetalle(_filtrados[i], dark),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showRolSheet(bool dark) {
    final roles = ['admin', 'user'];
    showModalBottomSheet(
      context: context,
      backgroundColor: SpotlyColors.card(dark),
      isScrollControlled: true,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4,
            decoration: BoxDecoration(
                color: SpotlyColors.subText(dark).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(16),
            child: Text('Filtrar por rol',
                style: TextStyle(color: SpotlyColors.text(dark),
                    fontSize: 16, fontWeight: FontWeight.bold))),
        const Divider(height: 1),
        Flexible(child: ListView(shrinkWrap: true, children: [
          ListTile(
            title: Text('Todos', style: TextStyle(color: SpotlyColors.text(dark))),
            trailing: _filtroRol == null
                ? Icon(LucideIcons.check, size: 16, color: SpotlyColors.accent(dark))
                : null,
            onTap: () {
              Navigator.pop(context);
              setState(() { _filtroRol = null; _aplicarFiltros(); });
            },
          ),
          ...roles.map((r) => ListTile(
            title: Text(r, style: TextStyle(color: SpotlyColors.text(dark))),
            trailing: _filtroRol == r
                ? Icon(LucideIcons.check, size: 16, color: SpotlyColors.accent(dark))
                : null,
            onTap: () {
              Navigator.pop(context);
              setState(() { _filtroRol = r; _aplicarFiltros(); });
            },
          )),
        ])),
        const SizedBox(height: 16),
      ]),
    );
  }

  void _showEstadoSheet(bool dark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SpotlyColors.card(dark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4,
            decoration: BoxDecoration(
                color: SpotlyColors.subText(dark).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(16),
            child: Text('Filtrar por estado',
                style: TextStyle(color: SpotlyColors.text(dark),
                    fontSize: 16, fontWeight: FontWeight.bold))),
        const Divider(height: 1),
        for (final item in [
          {'label': 'Todos', 'value': null},
          {'label': 'Activos', 'value': true},
          {'label': 'Baneados', 'value': false},
        ])
          ListTile(
            title: Text(item['label'] as String,
                style: TextStyle(color: SpotlyColors.text(dark))),
            trailing: _filtroActivo == item['value']
                ? Icon(LucideIcons.check, size: 16, color: SpotlyColors.accent(dark))
                : null,
            onTap: () {
              Navigator.pop(context);
              setState(() { _filtroActivo = item['value'] as bool?; _aplicarFiltros(); });
            },
          ),
        const SizedBox(height: 16),
      ]),
    );
  }
}

// ── Tarjeta ───────────────────────────────────────────────────────────────────

class _UsuarioCard extends StatelessWidget {
  final AdminUsuarioModel usuario;
  final bool dark;
  final VoidCallback onTap;

  const _UsuarioCard({required this.usuario, required this.dark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = SpotlyColors.accent(dark);
    final sub = SpotlyColors.subText(dark);

    // Color del borde según estado
    Color? borderColor;
    if (!usuario.esActivo) borderColor = Colors.redAccent.withOpacity(0.4);
    else if (usuario.reportesPendientes > 0) borderColor = const Color(0xFFF59E0B).withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: SpotlyColors.card(dark),
          borderRadius: BorderRadius.circular(14),
          boxShadow: SpotlyColors.shadow(dark),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: accent.withOpacity(0.15),
            backgroundImage: usuario.fotoPerfil != null &&
                    usuario.fotoPerfil!.startsWith('http')
                ? NetworkImage(usuario.fotoPerfil!)
                : null,
            child: usuario.fotoPerfil == null ||
                    !usuario.fotoPerfil!.startsWith('http')
                ? Text(
                    (usuario.nombres?.isNotEmpty == true
                            ? usuario.nombres![0]
                            : usuario.nombreUsuario?[0] ?? '?')
                        .toUpperCase(),
                    style: TextStyle(color: accent,
                        fontWeight: FontWeight.bold, fontSize: 18))
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(usuario.nombreCompleto,
                      style: TextStyle(color: SpotlyColors.text(dark),
                          fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: usuario.rol == 'admin'
                        ? accent.withOpacity(0.15)
                        : sub.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(usuario.rol,
                      style: TextStyle(
                          color: usuario.rol == 'admin' ? accent : sub,
                          fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 2),
              Text('@${usuario.nombreUsuario ?? ''}',
                  style: TextStyle(color: accent, fontSize: 11)),
              const SizedBox(height: 4),
              Row(children: [
                Icon(LucideIcons.image, size: 11, color: sub),
                const SizedBox(width: 3),
                Text('${usuario.pubCount}', style: TextStyle(color: sub, fontSize: 11)),
                const SizedBox(width: 10),
                Icon(LucideIcons.users, size: 11, color: sub),
                const SizedBox(width: 3),
                Text('${usuario.seguidoresCount}',
                    style: TextStyle(color: sub, fontSize: 11)),
                if (usuario.reportesPendientes > 0) ...[
                  const SizedBox(width: 10),
                  Icon(LucideIcons.flag, size: 11, color: const Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text('${usuario.reportesPendientes}',
                      style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 11)),
                ],
              ]),
              // Muestra fecha de fin de suspensión si aplica
              if (usuario.esBanTemporal) ...[
                const SizedBox(height: 3),
                Text(
                  'Suspendido hasta ${usuario.banHasta!.day}/${usuario.banHasta!.month}/${usuario.banHasta!.year}',
                  style: const TextStyle(color: Colors.orange, fontSize: 10),
                ),
              ],
            ]),
          ),
          Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: usuario.esActivo
                    ? Colors.green.withOpacity(0.12)
                    : usuario.esBanTemporal
                        ? Colors.orange.withOpacity(0.12)
                        : Colors.redAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                usuario.esActivo ? 'Activo'
                    : usuario.esBanTemporal ? 'Suspendido'
                    : 'Baneado',
                style: TextStyle(
                    color: usuario.esActivo ? Colors.green
                        : usuario.esBanTemporal ? Colors.orange
                        : Colors.redAccent,
                    fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 6),
            Icon(LucideIcons.chevronRight, size: 14, color: sub),
          ]),
        ]),
      ),
    );
  }
}

// ── Sheet de detalle ──────────────────────────────────────────────────────────

class _UsuarioDetalleSheet extends StatefulWidget {
  final AdminUsuarioModel usuario;
  final bool dark;
  final UsuariosRepository repo;
  final VoidCallback onActualizado;

  const _UsuarioDetalleSheet({
    required this.usuario,
    required this.dark,
    required this.repo,
    required this.onActualizado,
  });

  @override
  State<_UsuarioDetalleSheet> createState() => _UsuarioDetalleSheetState();
}

class _UsuarioDetalleSheetState extends State<_UsuarioDetalleSheet> {
  bool _procesando = false;

  // ── Ban con selector de tipo ───────────────────────────────────────────────

  Future<void> _mostrarOpcionesBan() async {
    final dark = widget.dark;
    final u = widget.usuario;

    // Si ya está baneado, solo desbanear
    if (!u.esActivo) {
      await _confirmarDesbanear();
      return;
    }

    // Selector: suspender 3 meses o banear definitivamente
    final tipoBan = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: SpotlyColors.card(dark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 12),
        Container(width: 36, height: 4,
            decoration: BoxDecoration(
                color: SpotlyColors.subText(dark).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2))),
        Padding(padding: const EdgeInsets.all(16),
            child: Text('Tipo de sanción',
                style: TextStyle(color: SpotlyColors.text(dark),
                    fontSize: 16, fontWeight: FontWeight.bold))),
        const Divider(height: 1),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.12),
                shape: BoxShape.circle),
            child: const Icon(LucideIcons.clock, color: Colors.orange, size: 18),
          ),
          title: Text('Suspender 3 meses',
              style: TextStyle(color: SpotlyColors.text(dark),
                  fontWeight: FontWeight.w600)),
          subtitle: Text('El usuario recupera acceso automáticamente',
              style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 12)),
          onTap: () => Navigator.of(context).pop('temporal'),
        ),
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.12),
                shape: BoxShape.circle),
            child: const Icon(LucideIcons.userX, color: Colors.redAccent, size: 18),
          ),
          title: Text('Baneo definitivo',
              style: TextStyle(color: SpotlyColors.text(dark),
                  fontWeight: FontWeight.w600)),
          subtitle: Text('El usuario no podrá acceder nunca',
              style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 12)),
          onTap: () => Navigator.of(context).pop('definitivo'),
        ),
        const SizedBox(height: 16),
      ]),
    );

    if (tipoBan == null || !mounted) return;
    await _confirmarBan(tipoBan);
  }

  Future<void> _confirmarBan(String tipoBan) async {
    final dark = widget.dark;
    final u = widget.usuario;
    final motivoCtrl = TextEditingController();

    final confirm = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SpotlyColors.bg(dark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 20, left: 20, right: 20,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(
                  color: SpotlyColors.subText(dark).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Icon(
            tipoBan == 'temporal' ? LucideIcons.clock : LucideIcons.userX,
            size: 40,
            color: tipoBan == 'temporal' ? Colors.orange : Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Text(
            tipoBan == 'temporal'
                ? 'Suspender 3 meses a @${u.nombreUsuario}'
                : 'Baneo definitivo a @${u.nombreUsuario}',
            textAlign: TextAlign.center,
            style: TextStyle(color: SpotlyColors.text(dark),
                fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: motivoCtrl,
            maxLines: 3,
            style: TextStyle(color: SpotlyColors.text(dark), fontSize: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: SpotlyColors.card(dark),
              hintText: 'Motivo (opcional)...',
              hintStyle: TextStyle(color: SpotlyColors.subText(dark)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Cancelar',
                    style: TextStyle(color: SpotlyColors.subText(dark))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tipoBan == 'temporal'
                      ? Colors.orange : Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  tipoBan == 'temporal' ? 'Suspender' : 'Banear',
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );

    if (confirm != true || !mounted) return;
    setState(() => _procesando = true);
    try {
      await widget.repo.banearUsuario(
        userId: u.id,
        tipoBan: tipoBan,
        motivoBan: motivoCtrl.text.trim().isEmpty ? null : motivoCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        widget.onActualizado();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _procesando = false);
      }
    }
  }

  Future<void> _confirmarDesbanear() async {
    final dark = widget.dark;
    final u = widget.usuario;

    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: SpotlyColors.card(dark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(
                  color: SpotlyColors.subText(dark).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Icon(LucideIcons.userCheck, size: 40, color: Colors.green),
          const SizedBox(height: 12),
          Text('Desbanear a @${u.nombreUsuario}',
              style: TextStyle(color: SpotlyColors.text(dark),
                  fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('El usuario recuperará el acceso a su cuenta.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 14)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: Text('Cancelar',
                    style: TextStyle(color: SpotlyColors.subText(dark))),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Desbanear',
                    style: TextStyle(color: Colors.white,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ]),
      ),
    );

    if (confirm != true || !mounted) return;
    setState(() => _procesando = true);
    try {
      await widget.repo.desbanearUsuario(u.id);
      if (mounted) {
        Navigator.of(context).pop();
        widget.onActualizado();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _procesando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final u = widget.usuario;
    final accent = SpotlyColors.accent(dark);
    final sub = SpotlyColors.subText(dark);
    final text = SpotlyColors.text(dark);

    return Container(
      decoration: BoxDecoration(
        color: SpotlyColors.bg(dark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: sub.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),

            // Avatar
            CircleAvatar(
              radius: 36,
              backgroundColor: accent.withOpacity(0.15),
              backgroundImage: u.fotoPerfil != null &&
                      u.fotoPerfil!.startsWith('http')
                  ? NetworkImage(u.fotoPerfil!)
                  : null,
              child: u.fotoPerfil == null || !u.fotoPerfil!.startsWith('http')
                  ? Text(
                      (u.nombres?.isNotEmpty == true
                              ? u.nombres![0]
                              : u.nombreUsuario?[0] ?? '?')
                          .toUpperCase(),
                      style: TextStyle(color: accent,
                          fontWeight: FontWeight.bold, fontSize: 24))
                  : null,
            ),
            const SizedBox(height: 12),
            Text(u.nombreCompleto,
                style: TextStyle(color: text, fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('@${u.nombreUsuario ?? ''}',
                style: TextStyle(color: accent, fontSize: 13)),
            if (u.email != null) ...[
              const SizedBox(height: 4),
              Text(u.email!, style: TextStyle(color: sub, fontSize: 12)),
            ],
            const SizedBox(height: 16),

            // Stats
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _StatItem(label: 'Publicaciones', value: '${u.pubCount}', dark: dark),
              Container(width: 1, height: 30, color: sub.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16)),
              _StatItem(label: 'Seguidores', value: '${u.seguidoresCount}', dark: dark),
              Container(width: 1, height: 30, color: sub.withOpacity(0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 16)),
              _StatItem(
                label: 'Reportes',
                value: '${u.reportesPendientes}',
                dark: dark,
                color: u.reportesPendientes > 0
                    ? const Color(0xFFF59E0B) : null,
              ),
            ]),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            _InfoRow(icon: LucideIcons.shield, label: 'Rol', value: u.rol, dark: dark),
            const SizedBox(height: 8),
            _InfoRow(
              icon: LucideIcons.calendar,
              label: 'Registro',
              value: u.fechaRegistro != null
                  ? '${u.fechaRegistro!.day}/${u.fechaRegistro!.month}/${u.fechaRegistro!.year}'
                  : 'Desconocido',
              dark: dark,
            ),

            // Estado del ban
            if (!u.esActivo) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: u.esBanTemporal ? LucideIcons.clock : LucideIcons.userX,
                label: u.esBanTemporal ? 'Suspendido hasta' : 'Estado',
                value: u.esBanTemporal
                    ? '${u.banHasta!.day}/${u.banHasta!.month}/${u.banHasta!.year}'
                    : 'Baneo definitivo',
                dark: dark,
              ),
              if (u.motivoBan != null) ...[
                const SizedBox(height: 8),
                _InfoRow(icon: LucideIcons.fileText,
                    label: 'Motivo', value: u.motivoBan!, dark: dark),
              ],
            ],

            // Reportes pendientes
            if (u.reportesPendientes > 0) ...[
              const SizedBox(height: 16),
              _ReportesSection(userId: u.id, dark: dark),
            ],

            const SizedBox(height: 20),

            // Botón de acción
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _procesando ? null : _mostrarOpcionesBan,
                icon: Icon(
                  u.esActivo ? LucideIcons.userX : LucideIcons.userCheck,
                  size: 16, color: Colors.white,
                ),
                label: Text(
                  u.esActivo ? 'Sancionar cuenta' : 'Desbanear cuenta',
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: u.esActivo ? Colors.redAccent : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sección de reportes ───────────────────────────────────────────────────────

class _ReportesSection extends StatefulWidget {
  final String userId;
  final bool dark;

  const _ReportesSection({required this.userId, required this.dark});

  @override
  State<_ReportesSection> createState() => _ReportesSectionState();
}

class _ReportesSectionState extends State<_ReportesSection> {
  List<Map<String, dynamic>> _reportes = [];
  bool _loading = true;
  bool _expandido = false;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    try {
      final data = await Supabase.instance.client
          .from('reportes_cuenta')
          .select('motivo, descripcion, created_at')
          .eq('id_usuario_reportado', widget.userId)
          .eq('pendiente', true)
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _reportes = List<Map<String, dynamic>>.from(data);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expandido = !_expandido),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                const Icon(LucideIcons.flag,
                    size: 16, color: Color(0xFFF59E0B)),
                const SizedBox(width: 8),
                Text('Ver reportes (${_reportes.length})',
                    style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const Spacer(),
                Icon(
                  _expandido ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 14, color: const Color(0xFFF59E0B),
                ),
              ]),
            ),
          ),
          if (_expandido) ...[
            Divider(color: const Color(0xFFF59E0B).withOpacity(0.2), height: 1),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              ..._reportes.map((r) {
                final motivo = r['motivo'] as String? ?? 'Sin motivo';
                final desc = r['descripcion'] as String?;
                final fecha = r['created_at'] != null
                    ? DateTime.tryParse(r['created_at'] as String)
                    : null;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6, height: 6, margin: const EdgeInsets.only(top: 5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(motivo,
                                style: TextStyle(
                                    color: SpotlyColors.text(dark),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            if (desc != null && desc.isNotEmpty)
                              Text(desc,
                                  style: TextStyle(
                                      color: SpotlyColors.subText(dark),
                                      fontSize: 12)),
                            if (fecha != null)
                              Text(
                                '${fecha.day}/${fecha.month}/${fecha.year}',
                                style: TextStyle(
                                    color: SpotlyColors.subText(dark),
                                    fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool dark;

  const _StatChip({required this.label, required this.value,
      required this.color, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(value, style: TextStyle(color: color,
            fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(
            color: SpotlyColors.subText(dark), fontSize: 11)),
      ]),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool dark;
  final VoidCallback onTap;

  const _FiltroChip({required this.label, required this.active,
      required this.dark, required this.onTap});

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
          Text(label, style: TextStyle(
              color: active ? accent : SpotlyColors.subText(dark),
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
          const SizedBox(width: 4),
          Icon(LucideIcons.chevronDown, size: 12,
              color: active ? accent : SpotlyColors.subText(dark)),
        ]),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool dark;
  final Color? color;

  const _StatItem({required this.label, required this.value,
      required this.dark, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(
          color: color ?? SpotlyColors.text(dark),
          fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(
          color: SpotlyColors.subText(dark), fontSize: 11)),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool dark;

  const _InfoRow({required this.icon, required this.label,
      required this.value, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: SpotlyColors.subText(dark)),
      const SizedBox(width: 8),
      Text('$label: ', style: TextStyle(
          color: SpotlyColors.subText(dark), fontSize: 13)),
      Expanded(
        child: Text(value, style: TextStyle(
            color: SpotlyColors.text(dark),
            fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }
}
