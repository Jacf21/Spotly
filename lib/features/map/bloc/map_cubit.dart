import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../data/models/map_lugar_model.dart';
import '../data/repositories/map_repository.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  final MapRepository repository;

  static const double _defaultRadioKm = 5.0;
  static const LatLng _fallbackCochabamba = LatLng(-17.3895, -66.1568);

  StreamSubscription<Position>? _posicionStream;

  MapCubit({required this.repository}) : super(MapInitial());

  Future<void> init({LatLng? lugarInicial}) async {
    emit(MapLoading());

    try {
      final lugares = await repository.getLugaresConCoordenadas();

      // 1. Obtener ubicación GPS (siempre la intentamos para el marcador azul)
      LatLng? miUbicacion;
      bool locationObtained = false;
      try {
        miUbicacion = await _obtenerUbicacion();
        locationObtained = true;
      } catch (_) {
        // Sin permisos o GPS apagado — continúa sin ubicación
      }

      // 2. Centro del mapa: lugar externo > mi ubicación > fallback
      final center = lugarInicial ?? miUbicacion ?? _fallbackCochabamba;

      final enZona = _filtrarEnZona(lugares, center, _defaultRadioKm);

      emit(MapLoaded(
        currentCenter: center,
        miUbicacion: miUbicacion,
        todosLugares: lugares,
        lugaresEnZona: enZona,
        radioKm: _defaultRadioKm,
        locationObtained: locationObtained,
      ));

      // 3. Inicia tracking continuo si tenemos permiso
      if (locationObtained) _iniciarTracking();
    } catch (e) {
      emit(MapError('Error cargando el mapa: $e'));
    }
  }

  // ── Tracking GPS en tiempo real ───────────────────────────────────────────

  void _iniciarTracking() {
    _posicionStream?.cancel();
    _posicionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // actualiza cada 10 metros para no saturar
      ),
    ).listen((pos) {
      final current = state;
      if (current is! MapLoaded) return;
      final nuevaUbicacion = LatLng(pos.latitude, pos.longitude);
      emit(current.copyWith(miUbicacion: nuevaUbicacion));
    });
  }

  LatLng? getMiUbicacion() {
    final current = state;
    if (current is MapLoaded) return current.miUbicacion;
    return null;
  }

  // ── Movimiento manual del mapa ────────────────────────────────────────────

  void updateCenter(LatLng newCenter) {
    final current = state;
    if (current is! MapLoaded) return;

    final enZona = _filtrarEnZona(current.todosLugares, newCenter, current.radioKm);
    emit(current.copyWith(
      currentCenter: newCenter,
      lugaresEnZona: enZona,
      clearLugarSeleccionado: false,
    ));
  }

  // ── Selección de marcador ─────────────────────────────────────────────────

  void seleccionarLugar(MapLugarModel lugar) {
    final current = state;
    if (current is! MapLoaded) return;
    emit(current.copyWith(lugarSeleccionado: lugar, clearRuta: true));
  }

  void cerrarLugarSeleccionado() {
    final current = state;
    if (current is! MapLoaded) return;
    emit(current.copyWith(
      clearLugarSeleccionado: true,
      clearRuta: true,
    ));
  }

  void soloLimpiarSeleccion() {
    final current = state;
    if (current is! MapLoaded) return;
    emit(current.copyWith(clearLugarSeleccionado: true));
  }

  Future<void> trazarRuta(LatLng destino) async {
    final current = state;
    if (current is! MapLoaded) return;

    final origen = current.miUbicacion;
    if (origen == null) return; // sin ubicación no podemos trazar

    try {
      final uri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${origen.longitude},${origen.latitude};'
        '${destino.longitude},${destino.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List<dynamic>;
      if (routes.isEmpty) return;

      final route = routes.first as Map<String, dynamic>;
      final distanciaM = (route['distance'] as num).toDouble();
      final duracionS = (route['duration'] as num).toDouble();

      // Decodifica los puntos GeoJSON
      final coords = (route['geometry']['coordinates'] as List<dynamic>)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      emit(current.copyWith(
        rutaActiva: RouteInfo(
          puntos: coords,
          distanciaKm: distanciaM / 1000,
          duracionMinutos: (duracionS / 60).round(),
        ),
      ));
    } catch (_) {
      // Error de red — simplemente no trazamos ruta
    }
  }

  void limpiarRuta() {
    final current = state;
    if (current is! MapLoaded) return;
    emit(current.copyWith(clearRuta: true));
  }

  // ── Búsqueda combinada ────────────────────────────────────────────────────

  Future<void> buscarLugar(String query) async {
    final current = state;
    if (current is! MapLoaded) return;

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(current.copyWith(resultadosBusqueda: [], buscando: false));
      return;
    }

    emit(current.copyWith(buscando: true, resultadosBusqueda: []));

    try {
      final results = await Future.wait([
        _buscarEnSupabase(trimmed, current.todosLugares),
        _buscarEnNominatim(trimmed),
      ]);

      final supabaseResults = results[0];
      final geocodingResults = results[1];

      final combined = <SearchResult>[...supabaseResults];
      for (final geo in geocodingResults) {
        final isDuplicate =
            combined.any((r) => _distanciaKm(r.coordenadas, geo.coordenadas) < 0.3);
        if (!isDuplicate) combined.add(geo);
      }

      // Solo emite si el cubit sigue cargado (el usuario no canceló)
      if (state is MapLoaded) {
        emit((state as MapLoaded).copyWith(
          resultadosBusqueda: combined,
          buscando: false,
        ));
      }
    } catch (_) {
      if (state is MapLoaded) {
        emit((state as MapLoaded).copyWith(
          resultadosBusqueda: [],
          buscando: false,
        ));
      }
    }
  }

  Future<List<SearchResult>> _buscarEnSupabase(
    String query,
    List<MapLugarModel> todosLugares,
  ) async {
    final q = _normalizar(query);
    final locales = todosLugares
        .where((l) => _normalizar(l.nombre).contains(q))
        .map((l) => SearchResult(
              titulo: l.nombre,
              subtitulo: '${l.categoria} · ${l.departamento}',
              coordenadas: l.coordenadas,
              esLugarRegistrado: true,
              lugar: l,
            ))
        .toList();

    if (locales.isNotEmpty || q.length < 3) return locales;

    try {
      final remotos = await repository.buscarLugares(query);
      return remotos
          .map((l) => SearchResult(
                titulo: l.nombre,
                subtitulo: '${l.categoria} · ${l.departamento}',
                coordenadas: l.coordenadas,
                esLugarRegistrado: true,
                lugar: l,
              ))
          .toList();
    } catch (_) {
      return locales;
    }
  }

  Future<List<SearchResult>> _buscarEnNominatim(String query) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query,
          'format': 'jsonv2',
          'limit': '5',
          'countrycodes': 'bo',
          'addressdetails': '1',
          'accept-language': 'es',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Accept-Language': 'es',
          'User-Agent': 'Spotly/1.0',
        },
      ).timeout(const Duration(seconds: 20)); // ← más tiempo para APK

      if (response.statusCode != 200) return [];
      
      final body = response.body.trim();
      if (body.isEmpty || body == '[]') return [];

      final List<dynamic> data = json.decode(body);
      
      return data.map((item) {
        final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0;
        final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0;
        final displayName = item['display_name'] as String? ?? '';
        final partes = displayName.split(',');
        final titulo = partes.first.trim();
        final subtitulo = partes.length > 1
            ? partes.skip(1).take(2).map((s) => s.trim()).join(', ')
            : null;
        return SearchResult(
          titulo: titulo,
          subtitulo: subtitulo,
          coordenadas: LatLng(lat, lon),
          esLugarRegistrado: false,
        );
      }).where((r) => r.coordenadas.latitude != 0).toList();
      
    } catch (e) {
      return [];
    }
  }

  // ── Navegar a resultado de búsqueda ───────────────────────────────────────

  void actualizarZonaBusqueda(LatLng coordenadas) {
    final current = state;
    if (current is! MapLoaded) return;
    final enZona = _filtrarEnZona(current.todosLugares, coordenadas, current.radioKm);
    emit(current.copyWith(
      currentCenter: coordenadas,
      lugaresEnZona: enZona,
      resultadosBusqueda: [],
      buscando: false,
    ));
  }

  void limpiarBusqueda() {
    final current = state;
    if (current is! MapLoaded) return;
    emit(current.copyWith(resultadosBusqueda: [], buscando: false));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<LatLng> _obtenerUbicacion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('GPS desactivado');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permiso de ubicación denegado');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permiso permanentemente denegado');
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  List<MapLugarModel> _filtrarEnZona(
    List<MapLugarModel> lugares,
    LatLng centro,
    double radioKm,
  ) =>
      lugares
          .where((l) => _distanciaKm(centro, l.coordenadas) <= radioKm)
          .toList();

  double _distanciaKm(LatLng a, LatLng b) {
    const R = 6371.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLon = _toRad(b.longitude - a.longitude);
    final lat1 = _toRad(a.latitude);
    final lat2 = _toRad(b.latitude);
    final x = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(x), sqrt(1 - x));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  String _normalizar(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n');

  @override
  Future<void> close() {
    _posicionStream?.cancel();
    return super.close();
  }
}