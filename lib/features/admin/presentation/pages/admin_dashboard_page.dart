import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _loading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final client = Supabase.instance.client;

    try {
      final hoy = DateTime.now();
      final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day).toIso8601String();

      // Obtener todos los datos
      final results = await Future.wait([
        client.from('perfiles').select('id_usuario').count(CountOption.exact),
        client.from('perfiles').select('id_usuario').gte('fecha_registro', inicioHoy).count(CountOption.exact),
        client.from('publicaciones').select('id_publicacion').eq('es_compartido', false).count(CountOption.exact),
        client.from('publicaciones').select('id_publicacion').eq('es_compartido', false).gte('created_at', inicioHoy).count(CountOption.exact),
        client.from('lugares').select('id_lugar').count(CountOption.exact),
        client.from('lugares').select('id_lugar').eq('es_destacado', true).count(CountOption.exact),
        client.from('reportes_publicaciones').select('id_reporte').eq('pendiente', true).count(CountOption.exact),
        client.from('reportes_cuenta').select('id').eq('pendiente', true).count(CountOption.exact),
      ]);

      if (!mounted) return;
      setState(() {
        _stats = {
          'totalUsuarios':      results[0].count,
          'usuariosHoy':        results[1].count,
          'totalPublicaciones': results[2].count,
          'publicacionesHoy':   results[3].count,
          'totalLugares':       results[4].count,
          'lugaresDestacados':  results[5].count,
          'reportesPendientes': results[6].count,
          'reportesCuentas':    results[7].count,
        };
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error cargando stats: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  /// Contructor de panel de administacion
  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  _buildHeader(dark),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Usuarios', dark),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          dark: dark,
                          icon: LucideIcons.users,
                          label: 'Total usuarios',
                          value: '${_stats['totalUsuarios'] ?? 0}',
                          accent: Colors.blue,
                          onTap: () => context.push('/admin/usuarios'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          dark: dark,
                          icon: LucideIcons.userPlus,
                          label: 'Nuevos hoy',
                          value: '+${_stats['usuariosHoy'] ?? 0}',
                          accent: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Publicaciones', dark),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          dark: dark,
                          icon: LucideIcons.image,
                          label: 'Total publicaciones',
                          value: '${_stats['totalPublicaciones'] ?? 0}',
                          accent: Colors.purple,
                          onTap: () => context.push('/admin/publicaciones'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          dark: dark,
                          icon: LucideIcons.calendarClock,
                          label: 'Publicadas hoy',
                          value: '+${_stats['publicacionesHoy'] ?? 0}',
                          accent: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Lugares', dark),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          dark: dark,
                          icon: LucideIcons.mapPin,
                          label: 'Total lugares',
                          value: '${_stats['totalLugares'] ?? 0}',
                          accent: Colors.orange,
                          onTap: () => context.push('/admin/lugares'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          dark: dark,
                          icon: LucideIcons.star,
                          label: 'Destacados',
                          value: '${_stats['lugaresDestacados'] ?? 0}',
                          accent: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Reportes', dark),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          dark: dark,
                          icon: LucideIcons.flag,
                          label: 'Publicaciones reportadas',
                          value: '${_stats['reportesPendientes'] ?? 0}',
                          accent: Colors.red,
                          badge: (_stats['reportesPendientes'] ?? 0) > 0,
                          onTap: () => context.push('/admin/publicaciones'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          dark: dark,
                          icon: LucideIcons.userX,
                          label: 'Cuentas reportadas',
                          value: '${_stats['reportesCuentas'] ?? 0}',
                          accent: Colors.deepOrange,
                          badge: (_stats['reportesCuentas'] ?? 0) > 0,
                          onTap: () => context.push('/admin/usuarios'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _buildQuickAccess(dark),
                ],
              ),
      ),
    );
  }

  /// Constructor global
  Widget _buildHeader(bool dark) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel de administración',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: SpotlyColors.text(dark),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Resumen general del sistema',
              style: TextStyle(
                fontSize: 13,
                color: SpotlyColors.subText(dark),
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: _loadStats,
          icon: Icon(LucideIcons.refreshCw,
              color: SpotlyColors.subText(dark), size: 20),
          tooltip: 'Actualizar',
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, bool dark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: SpotlyColors.subText(dark),
        letterSpacing: 0.5,
      ),
    );
  }

  /// Constructor de nelaces a otras secciones
  Widget _buildQuickAccess(bool dark) {
    final items = [
      (LucideIcons.users, 'Usuarios', '/admin/usuarios', Colors.blue),
      (LucideIcons.image, 'Publicaciones', '/admin/publicaciones', Colors.purple),
      (LucideIcons.mapPin, 'Lugares', '/admin/lugares', Colors.orange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Acceso rápido', dark),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.push(item.$3),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: SpotlyColors.card(dark),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: dark ? Colors.white10 : Colors.black.withOpacity(0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.$4.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.$1, color: item.$4, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: SpotlyColors.text(dark),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Icon(LucideIcons.chevronRight,
                        color: SpotlyColors.subText(dark), size: 18),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Stat card widget
class _StatCard extends StatelessWidget {
  final bool dark;
  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final bool badge;
  final VoidCallback? onTap;

  const _StatCard({
    required this.dark,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.badge = false,
    this.onTap,
  });

  /// Constructor de estilo global
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: SpotlyColors.card(dark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: badge
                ? accent.withOpacity(0.4)
                : (dark ? Colors.white10 : Colors.black.withOpacity(0.08)),
            width: badge ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 16),
                ),
                if (badge) ...[
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: SpotlyColors.text(dark),
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: SpotlyColors.subText(dark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}