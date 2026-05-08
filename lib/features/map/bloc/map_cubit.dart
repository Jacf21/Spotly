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

  MapCubit({required this.repository}) : super(MapInitial());

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    emit(MapLoading());
    try {
      final lugares = await repository.getLugaresConCoordenadas();

      LatLng center;
      bool locationObtained = false;
      try {
        center = await _getCurrentLocation();
        locationObtained = true;
      } catch (_) {
        center = _fallbackCochabamba;
      }

      final enZona = _filtrarEnZona(lugares, center, _defaultRadioKm);

      emit(MapLoaded(
        currentCenter: center,
        todosLugares: lugares,
        lugaresEnZona: enZona,
        radioKm: _defaultRadioKm,
        locationObtained: locationObtained,
      ));
    } catch (e) {
      emit(MapError('Error cargando el mapa: $e'));
    }
  }

  // ── Movimiento manual del mapa ────────────────────────────────────────────

  void updateCenter(LatLng newCenter) {
    final current = state;
    if (current is! MapLoaded) return;

    final enZona = _filtrarEnZona(
      current.todosLugares,
      newCenter,
      current.radioKm,
    );

    emit(current.copyWith(
      currentCenter: newCenter,
      lugaresEnZona: enZona,
    ));
  }

  // ── Búsqueda combinada: Supabase + Nominatim ──────────────────────────────

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
      // Lanza ambas búsquedas en paralelo
      final results = await Future.wait([
        _buscarEnSupabase(trimmed, current.todosLugares),
        _buscarEnNominatim(trimmed),
      ]);

      final supabaseResults = results[0];
      final geocodingResults = results[1];

      // Primero los lugares registrados, luego geocoding (sin duplicados por coords)
      final combined = <SearchResult>[];
      combined.addAll(supabaseResults);

      // Agrega resultados de geocoding que no estén muy cerca de un lugar ya listado
      for (final geo in geocodingResults) {
        final isDuplicate = combined.any(
          (r) => _distanciaKm(r.coordenadas, geo.coordenadas) < 0.3,
        );
        if (!isDuplicate) combined.add(geo);
      }

      emit(current.copyWith(
        resultadosBusqueda: combined,
        buscando: false,
      ));
    } catch (_) {
      emit(current.copyWith(resultadosBusqueda: [], buscando: false));
    }
  }

  /// Busca en los lugares ya cargados (sin viaje de red extra) con tolerancia
  /// de mayúsculas/minúsculas y acentos
  Future<List<SearchResult>> _buscarEnSupabase(
    String query,
    List<MapLugarModel> todosLugares,
  ) async {
    final q = _normalizar(query);

    // Filtra localmente primero (instantáneo)
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

    // Si hay resultados locales o la query es corta, no hace falta el RPC
    if (locales.isNotEmpty || q.length < 3) return locales;

    // Fallback: consulta al servidor (por si hay lugares que no se cargaron)
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

  /// Geocoding con Nominatim (OpenStreetMap) — sin API key, gratis
  Future<List<SearchResult>> _buscarEnNominatim(String query) async {
    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query,
          'format': 'json',
          'limit': '5',
          'countrycodes': 'bo', // prioriza Bolivia, puedes quitar para global
          'addressdetails': '1',
        },
      );

      final response = await http
          .get(uri, headers: {'Accept-Language': 'es'})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return [];

      final List<dynamic> data = json.decode(response.body);

      return data.map((item) {
        final lat = double.parse(item['lat'] as String);
        final lon = double.parse(item['lon'] as String);
        final displayName = item['display_name'] as String? ?? '';

        // Divide el nombre en título (primera parte) y subtítulo (resto)
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
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Navegación directa a un resultado ─────────────────────────────────────

  /// Retorna el LatLng al que debe moverse el mapa.
  /// La PAGE llama _mapController.move() con este valor para garantizar
  /// que el movimiento ocurra DESPUÉS del rebuild del BlocBuilder.
  void seleccionarResultado(SearchResult resultado) {
    final current = state;
    if (current is! MapLoaded) return;

    final enZona = _filtrarEnZona(
      current.todosLugares,
      resultado.coordenadas,
      current.radioKm,
    );

    emit(current.copyWith(
      currentCenter: resultado.coordenadas,
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

  Future<LatLng> _getCurrentLocation() async {
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
  ) {
    return lugares.where((l) {
      return _distanciaKm(centro, l.coordenadas) <= radioKm;
    }).toList();
  }

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

  /// Normaliza texto para comparación insensible a mayúsculas y acentos
  String _normalizar(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n');
}