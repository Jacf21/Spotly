// features/admin/presentation/pages/admin_publicaciones_page.dart

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';
import '../../data/datasources/publicaciones_datasource.dart';
import '../../data/repositories/publicaciones_repository_impl.dart';
import '../../domain/publicaciones_repository.dart';

class AdminPublicacionesPage extends StatefulWidget {
  const AdminPublicacionesPage({super.key});

  @override
  State<AdminPublicacionesPage> createState() => _AdminPublicacionesPageState();
}

class _AdminPublicacionesPageState extends State<AdminPublicacionesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PublicacionesRepository _repo;

  int _totalPublicaciones = 0;
  int _totalReportes = 0;
  int _conReportes = 0;
  List<Map<String, dynamic>> _reportadas = [];
  List<Map<String, dynamic>> _todas = [];
  bool _loadingStats = true;
  bool _loadingReportadas = true;
  bool _loadingTodas = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _repo = PublicacionesRepositoryImpl(
      PublicacionesDatasource(Supabase.instance.client),
    );
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadStats(), _loadReportadas(), _loadTodas()]);
  }

  Future<void> _loadStats() async {
    if (mounted) setState(() => _loadingStats = true);
    try {
      final stats = await _repo.getStats();
      if (mounted) {
        setState(() {
        _totalPublicaciones = stats.totalPublicaciones;
        _totalReportes = stats.totalReportes;
        _conReportes = stats.conReportes;
        _loadingStats = false;
      });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _loadReportadas() async {
    if (mounted) setState(() => _loadingReportadas = true);
    try {
      final data = await _repo.getReportadas();
      if (mounted) setState(() { _reportadas = data; _loadingReportadas = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingReportadas = false);
    }
  }

  Future<void> _loadTodas() async {
    if (mounted) setState(() => _loadingTodas = true);
    try {
      final data = await _repo.getTodas();
      if (mounted) setState(() { _todas = data; _loadingTodas = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingTodas = false);
    }
  }

  Future<void> _ignorarReportes(
      int pubId, String idUsuario, final dark) async {
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: SpotlyColors.card(dark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SpotlyColors.subText(dark).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              LucideIcons.checkCircle,
              size: 40,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            Text(
              'Ignorar reportes',
              style: TextStyle(
                color: SpotlyColors.text(dark),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¿Deseas ignorar estos reportes?\nLa publicación permanecerá activa y los reportes se marcarán como resueltos.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: SpotlyColors.subText(dark), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cancelar',
                      style: TextStyle(color: SpotlyColors.subText(dark))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ignorar',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _repo.ignorarReportes(
        pubId: pubId,
        idUsuario: idUsuario,
        adminId: Supabase.instance.client.auth.currentUser?.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reportes ignorados correctamente'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ── Modal de detalle de publicación ──────────────────────────────────────

  void _mostrarDetalle(Map<String, dynamic> pub, bool dark) {
    final titulo = pub['titulo'] ?? pub['descripcion_experiencia'] ?? 'Sin título';
    final descripcion = pub['descripcion_experiencia'] ?? '';
    final esActivo = pub['es_activo'] == true;
    final perfil = pub['perfiles'] as Map?;
    final usuario = perfil?['nombre_usuario'] ??
        '${perfil?['nombres'] ?? ''} ${perfil?['apellidos'] ?? ''}'.trim();
    // media_url se añade directamente en el datasource desde multimedia_publicaciones
    final mediaUrl = pub['media_url'] as String?;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: SpotlyColors.card(dark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            if (mediaUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  mediaUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: SpotlyColors.accent(dark).withOpacity(0.1),
                    child: Icon(LucideIcons.imageOff,
                        size: 48, color: SpotlyColors.subText(dark)),
                  ),
                ),
              )
            else
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: SpotlyColors.accent(dark).withOpacity(0.08),
                  child: Icon(LucideIcons.image,
                      size: 48, color: SpotlyColors.subText(dark)),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título + estado
                  Row(children: [
                    Expanded(
                      child: Text(titulo,
                          style: TextStyle(
                              color: SpotlyColors.text(dark),
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: esActivo
                            ? Colors.green.withOpacity(0.12)
                            : Colors.redAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        esActivo ? 'Activa' : 'Bloqueada',
                        style: TextStyle(
                            color: esActivo ? Colors.green : Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text('@$usuario',
                      style: TextStyle(
                          color: SpotlyColors.accent(dark), fontSize: 12)),
                  if (descripcion.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(descripcion,
                        style: TextStyle(
                            color: SpotlyColors.subText(dark),
                            fontSize: 13,
                            height: 1.5)),
                  ],
                  const SizedBox(height: 16),
                  // Botón cerrar
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Cerrar',
                          style: TextStyle(color: SpotlyColors.subText(dark))),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Toggle con modal de confirmación ─────────────────────────────────────

  Future<void> _toggleActivo(
      int pubId, String idUsuario, bool esActivoActual, final dark) async {
    final nuevoEstado = !esActivoActual;

    // Usamos BottomSheet en vez de Dialog — más robusto con navegadores anidados
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: SpotlyColors.card(dark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: SpotlyColors.subText(dark).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(
              nuevoEstado ? LucideIcons.eye : LucideIcons.eyeOff,
              size: 40,
              color: nuevoEstado ? Colors.green : Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              nuevoEstado ? 'Desbloquear publicación' : 'Bloquear publicación',
              style: TextStyle(
                color: SpotlyColors.text(dark),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nuevoEstado
                  ? '¿Deseas restaurar esta publicación al muro?'
                  : 'La publicación será ocultada y se notificará al usuario.',
              textAlign: TextAlign.center,
              style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Cancelar',
                      style: TextStyle(color: SpotlyColors.subText(dark))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        nuevoEstado ? Colors.green : Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    nuevoEstado ? 'Desbloquear' : 'Bloquear',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await _repo.toggleActivo(
        pubId: pubId,
        idUsuario: idUsuario,
        esActivoActual: esActivoActual,
        adminId: Supabase.instance.client.auth.currentUser?.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Publicación ${nuevoEstado ? 'desbloqueada' : 'bloqueada'}'),
            backgroundColor: nuevoEstado ? Colors.green : Colors.redAccent,
          ),
        );
        _loadAll();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Publicaciones',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: SpotlyColors.text(dark))),
              const SizedBox(height: 16),
              _loadingStats
                  ? const Center(child: CircularProgressIndicator())
                  : Row(children: [
                      _StatChip(
                          label: 'Total',
                          value: '$_totalPublicaciones',
                          icon: LucideIcons.image,
                          color: const Color(0xFF0EA5E9),
                          dark: dark),
                      const SizedBox(width: 10),
                      _StatChip(
                          label: 'Reportes',
                          value: '$_totalReportes',
                          icon: LucideIcons.flag,
                          color: const Color(0xFFF59E0B),
                          dark: dark),
                      const SizedBox(width: 10),
                      _StatChip(
                          label: 'Con reportes',
                          value: '$_conReportes',
                          icon: LucideIcons.alertTriangle,
                          color: Colors.redAccent,
                          dark: dark),
                    ]),
              const SizedBox(height: 16),
            ]),
          ),
          TabBar(
            controller: _tabController,
            labelColor: SpotlyColors.accent(dark),
            unselectedLabelColor: SpotlyColors.subText(dark),
            indicatorColor: SpotlyColors.accent(dark),
            tabs: [
              Tab(text: 'Pendientes ($_conReportes)'),
              Tab(text: 'Todas ($_totalPublicaciones)'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportadasTab(dark),
                _buildTodasTab(dark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportadasTab(bool dark) {
    if (_loadingReportadas) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_reportadas.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.checkCircle,
              size: 48, color: Colors.green.withOpacity(0.6)),
          const SizedBox(height: 12),
          Text('Sin reportes pendientes',
              style: TextStyle(color: SpotlyColors.subText(dark))),
        ]),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reportadas.length,
        itemBuilder: (_, i) {
          final item = _reportadas[i];
          final pub = item['publicaciones'] as Map<String, dynamic>;
          final reportes = item['reportes'] as List;
          return _PublicacionCard(
            pub: pub,
            dark: dark,
            badge: '${reportes.length} reporte${reportes.length > 1 ? 's' : ''}',
            badgeColor: Colors.redAccent,
            motivos: reportes
                .map((r) => r['motivo']?.toString() ?? '')
                .toList(),
            onToggle: () => _toggleActivo(
              pub['id_publicacion'] as int,
              pub['id_usuario'].toString(),
              pub['es_activo'] == true,
              dark,
            ),
            onIgnore: () => _ignorarReportes(
              pub['id_publicacion'] as int,
              pub['id_usuario'].toString(),
              dark,
            ),
            onTap: () => _mostrarDetalle(pub, dark),
          );
        },
      ),
    );
  }

  Widget _buildTodasTab(bool dark) {
    if (_loadingTodas) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _todas.length,
        itemBuilder: (_, i) => _PublicacionCard(
          pub: _todas[i],
          dark: dark,
          onToggle: () => _toggleActivo(
            _todas[i]['id_publicacion'] as int,
            _todas[i]['id_usuario'].toString(),
            _todas[i]['es_activo'] == true,
            dark,
          ),
          onIgnore: () => _ignorarReportes(
              _todas[i]['id_publicacion'] as int,
              _todas[i]['id_usuario'].toString(),
              dark,
            ),
          onTap: () => _mostrarDetalle(_todas[i], dark),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _PublicacionCard extends StatelessWidget {
  final Map<String, dynamic> pub;
  final bool dark;
  final String? badge;
  final Color? badgeColor;
  final List<String>? motivos;
  final VoidCallback onToggle;
  final VoidCallback onIgnore;
  final VoidCallback onTap;

  const _PublicacionCard({
    required this.pub,
    required this.dark,
    required this.onToggle,
    required this.onIgnore,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.motivos,
  });

  @override
  Widget build(BuildContext context) {
    final esActivo = pub['es_activo'] == true;
    final perfil = pub['perfiles'] as Map?;
    final usuario = perfil?['nombre_usuario'] ??
        '${perfil?['nombres'] ?? ''} ${perfil?['apellidos'] ?? ''}'.trim();
    final titulo =
        pub['titulo'] ?? pub['descripcion_experiencia'] ?? 'Sin título';

    return GestureDetector(
      onTap: onTap, // toca la tarjeta → ver detalle
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SpotlyColors.card(dark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: esActivo
                  ? Colors.transparent
                  : Colors.redAccent.withOpacity(0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: SpotlyColors.text(dark),
                            fontWeight: FontWeight.w600)),
                    Text('@$usuario',
                        style: TextStyle(
                            color: SpotlyColors.accent(dark), fontSize: 12)),
                  ]),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: (badgeColor ?? Colors.grey).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(badge!,
                    style: TextStyle(
                        color: badgeColor ?? Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
            const SizedBox(width: 8),
            if (badge != null) ...[
              GestureDetector(
                onTap: onIgnore,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.checkCircle,
                        size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Text('Ignorar',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
            ],
            // Botón toggle — stopPropagation para no abrir detalle al tocar
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: esActivo
                      ? Colors.green.withOpacity(0.12)
                      : Colors.redAccent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(esActivo ? LucideIcons.eye : LucideIcons.eyeOff,
                      size: 14,
                      color: esActivo ? Colors.green : Colors.redAccent),
                  const SizedBox(width: 4),
                  Text(esActivo ? 'Activa' : 'Bloqueada',
                      style: TextStyle(
                          color: esActivo ? Colors.green : Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
          if (motivos != null && motivos!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text('Motivos:',
                style: TextStyle(
                    color: SpotlyColors.subText(dark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: motivos!
                  .where((m) => m.isNotEmpty)
                  .toSet()
                  .map((m) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(m,
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 11)),
                      ))
                  .toList(),
            ),
          ],
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool dark;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label,
              style:
                  TextStyle(color: SpotlyColors.subText(dark), fontSize: 10)),
        ]),
      ),
    );
  }
}