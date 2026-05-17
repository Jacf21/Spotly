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
import '../../data/models/map_lugar_model.dart';
import '../../data/repositories/map_repository.dart';
import '../../bloc/map_cubit.dart';
import '../../bloc/map_state.dart';
import '../widgets/explorar_zona_modal.dart';
import '../widgets/lugar_bottom_sheet.dart'; // NUEVO

// ─────────────────────────────────────────────────────────────────────────────
//  MapPage
//
//  Parámetros opcionales (pasados via GoRouter):
//    • lugarInicial: LatLng  → centra el mapa en ese lugar al abrir
//    • lugarModel: MapLugarModel → muestra el bottom sheet del lugar al abrir
// ─────────────────────────────────────────────────────────────────────────────

class MapPage extends StatefulWidget {
  /// Si se navega desde el perfil de un lugar, pasa sus coordenadas aquí.
  final LatLng? lugarInicial;

  const MapPage({super.key, this.lugarInicial});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  // ── Controladores ──────────────────────────────────────────────────────────
  late final MapController _mapController;
  late final MapCubit _cubit;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  Timer? _debounce;

  // ── Estado LOCAL de búsqueda ──────────────────────────────────────────────
  // Guardamos los resultados aquí para que el dropdown no se destruya cuando
  // el cubit emite un nuevo estado (eso era el bug original).
  List<SearchResult> _resultadosLocales = [];
  bool _showResults = false;
  bool _buscando = false;

  // Flag para evitar abrir el bottom sheet múltiples veces
  bool _sheetAbierto = false;

  // ── Zoom de animación para "volver a mi ubicación" ────────────────────────
  late final AnimationController _recenterAnim;

  @override
  void initState() {
    super.initState();

    _mapController = MapController();

    _cubit = MapCubit(
      repository: MapRepository(
        MapRemoteDatasource(Supabase.instance.client),
      ),
    );

    // Animación de pulso del círculo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.06, end: 0.16).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Animación del botón de re-centrar
    _recenterAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Inicia el cubit con el lugar inicial (puede ser null)
    _cubit.init(lugarInicial: widget.lugarInicial);

    // Oculta dropdown cuando pierde foco, pero con delay para que
    // onTap del resultado se complete primero (sin delay se cancela el tap)
    _searchFocus.addListener(() {
      if (!mounted) return;
      if (!_searchFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showResults = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    _cubit.close();
    _pulseController.dispose();
    _recenterAnim.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Búsqueda con debounce ─────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      _cubit.limpiarBusqueda();
      if (mounted) {
        setState(() {
          _resultadosLocales = [];
          _showResults = false;
          _buscando = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _buscando = true);

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      await _cubit.buscarLugar(query);

      if (!mounted) return;
      final s = _cubit.state;
      if (s is MapLoaded) {
        setState(() {
          _resultadosLocales = List.from(s.resultadosBusqueda);
          _buscando = false;
          _showResults = _resultadosLocales.isNotEmpty || _searchFocus.hasFocus;
        });
      }
    });
  }

  // ── Selección de resultado ────────────────────────────────────────────────
  // FIX PRINCIPAL: primero actualizamos estado local y movemos el mapa,
  // DESPUÉS actualizamos el cubit. Así el dropdown ya desapareció cuando
  // el BlocBuilder reconstruye, evitando el tap interrumpido.

  void _seleccionarResultado(SearchResult resultado) {
    // Con onTapDown esto se ejecuta ANTES del cambio de foco,
    // así que el mapa se mueve siempre sin importar el estado del teclado.

    // 1. Actualiza el texto y oculta el dropdown
    _searchController.text = resultado.titulo;
    setState(() {
      _resultadosLocales = [];
      _showResults = false;
      _buscando = false;
    });

    final zoom = resultado.esLugarRegistrado ? 15.0 : 13.0;

    // 2. Mueve el mapa — igual que _irAMiUbicacion
    _mapController.move(resultado.coordenadas, zoom);

    // 3. Actualiza zona en el cubit sin interferir con el move()
    Future.microtask(() {
      if (mounted) _cubit.actualizarZonaBusqueda(resultado.coordenadas);
    });
  }

  // ── Volver a mi ubicación ─────────────────────────────────────────────────

  void _irAMiUbicacion() {
    final ubicacion = _cubit.getMiUbicacion();
    if (ubicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ubicación no disponible. Activa el GPS.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _mapController.move(ubicacion, 15.0);
  }

  // ── Toque en marcador ─────────────────────────────────────────────────────

  void _onMarkerTap(MapLugarModel lugar) {
    _searchFocus.unfocus();
    _cubit.seleccionarLugar(lugar);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return BlocConsumer<MapCubit, MapState>(
      bloc: _cubit,
      listener: (context, state) {
        if (state is MapLoaded) {
          // Abre el sheet solo si hay lugar seleccionado Y el sheet no está ya abierto
          if (state.lugarSeleccionado != null && !_sheetAbierto) {
            _sheetAbierto = true;
            _mostrarLugarBottomSheet(context, state.lugarSeleccionado!, dark, state);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: SpotlyColors.bg(dark),
          body: Stack(
            children: [
              // ── Mapa base ──────────────────────────────────────────────────
              _buildMap(state, dark),

              // ── Overlays de estado (loading / error / loaded) ──────────────
              if (state is MapLoading) _buildLoadingOverlay(dark),
              if (state is MapError) _buildError(state.message, dark),
              if (state is MapLoaded) ...[
                // Círculo de zona animado
                _buildCircleOverlay(dark),
                // Ruta info banner
                if (state.rutaActiva != null) _buildRutaBanner(state.rutaActiva!, dark),
                // Barra de búsqueda
                _buildSearchBar(dark),
                // FAB explorar zona
                _buildExploreFab(state, dark),
                // FAB volver a mi ubicación
                _buildRecenterFab(dark),
              ],

              // ── Dropdown de resultados (FUERA del BlocBuilder) ────────────
              // Controlado por estado local para que onTap nunca sea
              // interrumpido por un rebuild del árbol.
              if (_showResults) _buildSearchResults(dark),
            ],
          ),
        );
      },
    );
  }

  // ── Mapa ───────────────────────────────────────────────────────────────────

  Widget _buildMap(MapState state, bool dark) {
    final loaded = state is MapLoaded ? state : null;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: widget.lugarInicial ?? const LatLng(-17.3895, -66.1568),
        initialZoom: 13.0,
        minZoom: 4.0,
        maxZoom: 19.0,
        onTap: (_, __) {
          // Cierra bottom sheet si está abierto
          if (loaded?.lugarSeleccionado != null) {
            _cubit.cerrarLugarSeleccionado();
            Navigator.of(context).popUntil((r) => r.isFirst);
          }
        },
        onPositionChanged: (position, hasGesture) {
          if (hasGesture) {
            final center = position.center;
            if (center != null) {
              _cubit.updateCenter(center);
            }
          }
        },
      ),
      children: [
        // Tiles del mapa
        TileLayer(
          urlTemplate: dark
              ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png'
              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.spotly',
        ),

        // Ruta trazada
        if (loaded?.rutaActiva != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: loaded!.rutaActiva!.puntos,
                color: SpotlyColors.accent(dark),
                strokeWidth: 5.0,
                borderColor: SpotlyColors.accent(dark).withOpacity(0.3),
                borderStrokeWidth: 10.0,
              ),
            ],
          ),

        // Marcadores de lugares
        if (loaded != null)
          MarkerLayer(
            markers: loaded.todosLugares.map((l) {
              final inZone = loaded.lugaresEnZona.any((z) => z.id == l.id);
              final isSelected = loaded.lugarSeleccionado?.id == l.id;
              return Marker(
                point: l.coordenadas,
                width: isSelected ? 44 : 36,
                height: isSelected ? 44 : 36,
                child: GestureDetector(
                  onTap: () => _onMarkerTap(l),
                  child: _LugarMarker(
                    dark: dark,
                    inZone: inZone,
                    isSelected: isSelected,
                    accent: SpotlyColors.accent(dark),
                  ),
                ),
              );
            }).toList(),
          ),

        // Marcador de MI UBICACIÓN (punto azul pulsante)
        if (loaded?.miUbicacion != null)
          MarkerLayer(
            markers: [
              Marker(
                point: loaded!.miUbicacion!,
                width: 24,
                height: 24,
                child: _MiUbicacionMarker(pulseAnim: _pulseAnim),
              ),
            ],
          ),
      ],
    );
  }

  // ── Bottom sheet del lugar seleccionado ───────────────────────────────────

  void _mostrarLugarBottomSheet(
    BuildContext context,
    MapLugarModel lugar,
    bool dark,
    MapLoaded state,
  ) {
    _mapController.move(lugar.coordenadas, 15.5);

    bool eligioRuta = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (_) => LugarBottomSheet(
        lugar: lugar,
        dark: dark,
        tieneUbicacion: state.miUbicacion != null,
        onComoLlegar: () {
          eligioRuta = true;
          Navigator.of(context).pop();
        },
      ),
    ).whenComplete(() {
      _sheetAbierto = false;

      if (eligioRuta) {
        // Limpia solo el marcador, NO la ruta — luego traza
        _cubit.soloLimpiarSeleccion();
        _cubit.trazarRuta(lugar.coordenadas);
        if (state.miUbicacion != null) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: LatLngBounds.fromPoints([
                    state.miUbicacion!,
                    lugar.coordenadas,
                  ]),
                  padding: const EdgeInsets.all(60),
                ),
              );
            }
          });
        }
      } else {
        // Cerró sin elegir ruta: limpia todo
        _cubit.cerrarLugarSeleccionado();
      }
    });
  }

  // ── Círculo de zona ────────────────────────────────────────────────────────

  Widget _buildCircleOverlay(bool dark) {
    final accent = SpotlyColors.accent(dark);
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, __) => CustomPaint(
            painter: _CirclePainter(
              color: accent.withOpacity(_pulseAnim.value),
              borderColor: accent.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }

  // ── Banner de ruta activa ─────────────────────────────────────────────────

  Widget _buildRutaBanner(RouteInfo ruta, bool dark) {
    final accent = SpotlyColors.accent(dark);
    return Positioned(
      // Sube el banner para que no tape el FAB de re-centrar (bottom: 100)
      // El FAB de explorar zona está en bottom: 28, este queda encima de ambos
      bottom: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: SpotlyColors.card(dark),
          borderRadius: BorderRadius.circular(16),
          boxShadow: SpotlyColors.shadow(dark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.navigation, size: 14, color: accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${ruta.distanciaKm.toStringAsFixed(1)} km · ${ruta.duracionMinutos} min',
                    style: TextStyle(
                      color: SpotlyColors.text(dark),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'En coche',
                    style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 11),
                  ),
                ],
              ),
            ),
            // Botón X con área de toque grande para no confundirlo con el FAB
            GestureDetector(
              onTap: _cubit.limpiarRuta,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(LucideIcons.x, size: 16, color: SpotlyColors.subText(dark)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Barra de búsqueda ─────────────────────────────────────────────────────

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
                        key: const ValueKey('spin'),
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: accent),
                      )
                    : Icon(
                        key: const ValueKey('icon'),
                        LucideIcons.search,
                        size: 18,
                        color: sub,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  onChanged: _onSearchChanged,
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
                      _showResults = false;
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

  // ── Dropdown de resultados (controlado por estado LOCAL) ──────────────────

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
                      final r = _resultadosLocales[i];
                      return GestureDetector(
                        // onTapDown se dispara ANTES de que el TextField
                        // pierda el foco, garantizando que la selección
                        // siempre se procesa sin importar si hubo Enter previo
                        onTapDown: (_) => _seleccionarResultado(r),
                        behavior: HitTestBehavior.opaque,
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
                                  color: r.esLugarRegistrado ? accent : sub,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                Icon(Icons.verified, size: 14, color: accent),
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

  // ── FAB Explorar zona ─────────────────────────────────────────────────────

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
              onLugarTap: (lugar) {
                // Mueve el mapa al lugar y abre su LugarBottomSheet
                _mapController.move(lugar.coordenadas, 15.5);
                _cubit.seleccionarLugar(lugar);
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
                  count > 0 ? 'Explorar zona  ($count)' : 'Explorar zona',
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

  // ── FAB Re-centrar (volver a mi ubicación) ─────────────────────────────────

  Widget _buildRecenterFab(bool dark) {
    final card = SpotlyColors.card(dark);
    final accent = SpotlyColors.accent(dark);

    return Positioned(
      bottom: 160,
      right: 16,
      child: FloatingActionButton.small(
        heroTag: 'recenter',
        backgroundColor: card,
        elevation: 4,
        onPressed: _irAMiUbicacion,
        child: Icon(LucideIcons.locateFixed, size: 18, color: accent),
      ),
    );
  }

  // ── Loading / Error ────────────────────────────────────────────────────────

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
              onPressed: () => _cubit.init(lugarInicial: widget.lugarInicial),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Marcadores
// ─────────────────────────────────────────────────────────────────────────────

class _LugarMarker extends StatelessWidget {
  final bool dark;
  final bool inZone;
  final bool isSelected;
  final Color accent;

  const _LugarMarker({
    required this.dark,
    required this.inZone,
    required this.isSelected,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Colors.orange
        : inZone
            ? accent
            : (dark ? Colors.white24 : Colors.black26);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: (inZone || isSelected) ? Colors.white : Colors.transparent,
          width: isSelected ? 3 : 2,
        ),
        boxShadow: (inZone || isSelected)
            ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: isSelected ? 12 : 6,
                  spreadRadius: isSelected ? 3 : 1,
                ),
              ]
            : null,
      ),
      child: Icon(
        isSelected ? LucideIcons.mapPin : LucideIcons.mapPin,
        size: isSelected ? 20 : 16,
        color: (inZone || isSelected) ? Colors.white : SpotlyColors.subText(dark),
      ),
    );
  }
}

/// Marcador azul pulsante que representa la posición real del usuario
class _MiUbicacionMarker extends StatelessWidget {
  final Animation<double> pulseAnim;

  const _MiUbicacionMarker({required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          // Halo exterior pulsante
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(pulseAnim.value * 0.8),
            ),
          ),
          // Punto interior fijo
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Painter del círculo de zona
// ─────────────────────────────────────────────────────────────────────────────

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