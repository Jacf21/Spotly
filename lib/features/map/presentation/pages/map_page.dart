import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';

import '../../data/datasources/map_remote_datasource.dart';
import '../../data/repositories/map_repository.dart';
import '../../bloc/map_cubit.dart';
import '../../bloc/map_state.dart';
import '../widgets/explorar_zona_modal.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  late final MapController _mapController;
  late final MapCubit _cubit;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  LatLng _center = const LatLng(-17.3895, -66.1568);

  // ── CLAVE DEL FIX ──────────────────────────────────────────────────────────
  // Los resultados se guardan aquí en el State, NO se leen del cubit state.
  // Así el widget de resultados NO se destruye cuando el cubit emite un nuevo
  // estado, y el onTap puede completarse sin interrupciones.
  List<SearchResult> _resultadosLocales = [];
  bool _showSearchResults = false;
  bool _buscando = false;
  // ──────────────────────────────────────────────────────────────────────────

  // Zona actual para el FAB (se actualiza desde el cubit)
  List<dynamic> _lugaresEnZona = [];

  static const double _radioMetros = 5000.0;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();

    _cubit = MapCubit(
      repository: MapRepository(
        MapRemoteDatasource(Supabase.instance.client),
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.08, end: 0.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cubit.init();

    _searchFocus.addListener(() {
      if (!mounted) return;
      setState(() {
        _showSearchResults =
            _searchFocus.hasFocus && _resultadosLocales.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _cubit.close();
    _pulseController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Búsqueda ───────────────────────────────────────────────────────────────

  void _onSearch(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      _cubit.limpiarBusqueda();
      if (mounted) setState(() {
        _resultadosLocales = [];
        _showSearchResults = false;
        _buscando = false;
      });
      return;
    }

    if (mounted) setState(() {
      _buscando = true;
      _showSearchResults = true;
    });

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      await _cubit.buscarLugar(query);
      // Copia los resultados al State local inmediatamente después de la búsqueda
      final state = _cubit.state;
      if (state is MapLoaded && mounted) {
        setState(() {
          _resultadosLocales = List.from(state.resultadosBusqueda);
          _buscando = false;
          _showSearchResults = _resultadosLocales.isNotEmpty;
        });
      }
    });
  }

  // ── Selección — aquí está el fix principal ─────────────────────────────────

  void _seleccionarResultado(SearchResult resultado) {
    // 1. Cierra el teclado y oculta resultados ANTES de tocar el cubit
    _searchFocus.unfocus();
    _searchController.text = resultado.titulo;

    // 2. Limpia los resultados locales (oculta el dropdown)
    setState(() {
      _resultadosLocales = [];
      _showSearchResults = false;
      _buscando = false;
    });

    final zoom = resultado.esLugarRegistrado ? 15.0 : 13.0;
    final coords = resultado.coordenadas;

    // 3. Mueve el mapa PRIMERO — el controller es independiente del BlocBuilder
    _mapController.move(coords, zoom);
    if (mounted) setState(() => _center = coords);

    // 4. Actualiza el cubit (círculo + zona) — esto puede emitir estado nuevo
    //    pero ya no hay ningún widget de resultados que se pueda destruir
    _cubit.seleccionarResultado(resultado);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return BlocListener<MapCubit, MapState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is MapLoaded && mounted) {
          // Sincroniza centro inicial cuando el GPS responde
          if (_center == const LatLng(-17.3895, -66.1568) &&
              state.locationObtained) {
            final newCenter = state.currentCenter;
            _mapController.move(newCenter, 13.0);
            setState(() => _center = newCenter);
          }
          // Sincroniza la zona para el FAB
          setState(() => _lugaresEnZona = state.lugaresEnZona);
        }
      },
      child: Scaffold(
        backgroundColor: SpotlyColors.bg(dark),
        body: Stack(
          children: [
            // Mapa — construido UNA SOLA VEZ
            _buildMap(dark),

            // Overlays que sí pueden reconstruirse
            BlocBuilder<MapCubit, MapState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state is MapLoading) return _buildLoadingOverlay(dark);
                if (state is MapError) return _buildError(state.message, dark);
                if (state is MapLoaded) {
                  return Stack(
                    children: [
                      _buildCircleOverlay(dark),
                      _buildSearchBar(dark),
                      _buildExploreFab(state, dark),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Resultados de búsqueda — FUERA del BlocBuilder, controlados por
            // el State local para que onTap nunca sea interrumpido
            if (_showSearchResults) _buildSearchResults(dark),
          ],
        ),
      ),
    );
  }

  // ── Mapa ───────────────────────────────────────────────────────────────────

  Widget _buildMap(bool dark) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _center,
        initialZoom: 13.0,
        minZoom: 4.0,
        maxZoom: 19.0,
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture && camera.center != null) {
            _cubit.updateCenter(camera.center!);
            if (mounted) setState(() => _center = camera.center!);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: dark
              ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png'
              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.spotly',
        ),
        BlocBuilder<MapCubit, MapState>(
          bloc: _cubit,
          buildWhen: (prev, curr) {
            if (prev is MapLoaded && curr is MapLoaded) {
              return prev.todosLugares != curr.todosLugares ||
                  prev.lugaresEnZona != curr.lugaresEnZona;
            }
            return true;
          },
          builder: (_, state) {
            if (state is! MapLoaded) return const SizedBox.shrink();
            final accent = SpotlyColors.accent(dark);
            return MarkerLayer(
              markers: state.todosLugares.map((l) {
                final inZone = state.lugaresEnZona.any((z) => z.id == l.id);
                return Marker(
                  point: l.coordenadas,
                  width: 36,
                  height: 36,
                  child: _MapMarker(dark: dark, inZone: inZone, accent: accent),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // ── Círculo overlay ────────────────────────────────────────────────────────

  Widget _buildCircleOverlay(bool dark) {
    final accent = SpotlyColors.accent(dark);
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => CustomPaint(
            painter: _CirclePainter(
              color: accent.withOpacity(_pulseAnim.value),
              borderColor: accent.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  // ── Buscador ───────────────────────────────────────────────────────────────

  Widget _buildSearchBar(bool dark) {
    final card = SpotlyColors.card(dark);
    final sub = SpotlyColors.subText(dark);
    final text = SpotlyColors.text(dark);
    final accent = SpotlyColors.accent(dark);

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: SpotlyColors.shadow(dark),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _buscando
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: accent),
                      )
                    : Icon(key: const ValueKey('icon'),
                        LucideIcons.search, size: 18, color: sub),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: _onSearch,
                  textCapitalization: TextCapitalization.none,
                  style: TextStyle(color: text, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ciudad, calle o lugar...',
                    hintStyle: TextStyle(color: sub, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(LucideIcons.x, size: 16, color: sub),
                  onPressed: () {
                    _searchController.clear();
                    _cubit.limpiarBusqueda();
                    setState(() {
                      _resultadosLocales = [];
                      _showSearchResults = false;
                      _buscando = false;
                    });
                    _searchFocus.unfocus();
                  },
                )
              else
                const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }

  // ── Resultados — completamente fuera del BlocBuilder ──────────────────────

  Widget _buildSearchResults(bool dark) {
    final card = SpotlyColors.card(dark);
    final accent = SpotlyColors.accent(dark);
    final text = SpotlyColors.text(dark);
    final sub = SpotlyColors.subText(dark);

    return Positioned(
      top: 86,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              boxShadow: SpotlyColors.shadow(dark),
            ),
            child: _buscando && _resultadosLocales.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    itemCount: _resultadosLocales.length,
                    itemBuilder: (_, i) {
                      // Snapshot del resultado en el momento del build
                      final r = _resultadosLocales[i];
                      return InkWell(
                        onTap: () => _seleccionarResultado(r),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: r.esLugarRegistrado
                                      ? accent.withOpacity(0.15)
                                      : sub.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  r.esLugarRegistrado
                                      ? LucideIcons.mapPin
                                      : LucideIcons.navigation,
                                  size: 14,
                                  color:
                                      r.esLugarRegistrado ? accent : sub,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.titulo,
                                      style: TextStyle(
                                        color: text,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (r.subtitulo != null)
                                      Text(
                                        r.subtitulo!,
                                        style: TextStyle(
                                            color: sub, fontSize: 11),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              if (r.esLugarRegistrado &&
                                  r.lugar?.esVerificado == true)
                                Icon(Icons.verified,
                                    size: 14, color: accent),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────

  Widget _buildExploreFab(MapLoaded state, bool dark) {
    final accent = SpotlyColors.accent(dark);
    final count = state.lugaresEnZona.length;

    return Positioned(
      bottom: 28,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () {
            _searchFocus.unfocus();
            ExplorarZonaModal.show(
              context,
              lugares: state.lugaresEnZona,
              dark: dark,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.45),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.compass,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  count > 0
                      ? 'Explorar zona  ($count)'
                      : 'Explorar zona',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Loading ────────────────────────────────────────────────────────────────

  Widget _buildLoadingOverlay(bool dark) {
    return Container(
      color: SpotlyColors.bg(dark).withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: SpotlyColors.accent(dark)),
            const SizedBox(height: 16),
            Text('Cargando mapa...',
                style: TextStyle(
                    color: SpotlyColors.text(dark), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError(String message, bool dark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.map,
                size: 52, color: SpotlyColors.subText(dark)),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: SpotlyColors.text(dark), fontSize: 15)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _cubit.init,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Marcador ──────────────────────────────────────────────────────────────────

class _MapMarker extends StatelessWidget {
  final bool dark;
  final bool inZone;
  final Color accent;

  const _MapMarker({
    required this.dark,
    required this.inZone,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: inZone ? accent : (dark ? Colors.white24 : Colors.black26),
        shape: BoxShape.circle,
        border: Border.all(
          color: inZone ? Colors.white : Colors.transparent,
          width: 2,
        ),
        boxShadow: inZone
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        LucideIcons.mapPin,
        size: 16,
        color: inZone ? Colors.white : SpotlyColors.subText(dark),
      ),
    );
  }
}

// ── Painter del círculo ────────────────────────────────────────────────────────

class _CirclePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _CirclePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.40;

    canvas.drawCircle(center, radius, Paint()..color = color);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter old) =>
      old.color != color || old.borderColor != borderColor;
}