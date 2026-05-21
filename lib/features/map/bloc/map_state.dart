import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/map_lugar_model.dart';

// ─────────────────────────────────────────────
//  SearchResult — resultado unificado (Supabase + Nominatim)
// ─────────────────────────────────────────────

class SearchResult {
  final String titulo;
  final String? subtitulo;
  final LatLng coordenadas;
  final bool esLugarRegistrado;
  final MapLugarModel? lugar;

  const SearchResult({
    required this.titulo,
    this.subtitulo,
    required this.coordenadas,
    required this.esLugarRegistrado,
    this.lugar,
  });
}

// ─────────────────────────────────────────────
//  RouteInfo — ruta calculada por OSRM
// ─────────────────────────────────────────────

class RouteInfo {
  final List<LatLng> puntos;
  final double distanciaKm;
  final int duracionMinutos;

  const RouteInfo({
    required this.puntos,
    required this.distanciaKm,
    required this.duracionMinutos,
  });
}

// ─────────────────────────────────────────────
//  Estados
// ─────────────────────────────────────────────

abstract class MapState extends Equatable {
  const MapState();
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final LatLng currentCenter;
  final LatLng? miUbicacion;           // posición GPS real del usuario
  final List<MapLugarModel> todosLugares;
  final List<MapLugarModel> lugaresEnZona;
  final double radioKm;
  final bool locationObtained;
  final List<SearchResult> resultadosBusqueda;
  final bool buscando;
  final MapLugarModel? lugarSeleccionado; // marcador tocado
  final RouteInfo? rutaActiva;           // ruta trazada

  const MapLoaded({
    required this.currentCenter,
    this.miUbicacion,
    required this.todosLugares,
    required this.lugaresEnZona,
    required this.radioKm,
    required this.locationObtained,
    this.resultadosBusqueda = const [],
    this.buscando = false,
    this.lugarSeleccionado,
    this.rutaActiva,
  });

  MapLoaded copyWith({
    LatLng? currentCenter,
    LatLng? miUbicacion,
    List<MapLugarModel>? todosLugares,
    List<MapLugarModel>? lugaresEnZona,
    double? radioKm,
    bool? locationObtained,
    List<SearchResult>? resultadosBusqueda,
    bool? buscando,
    MapLugarModel? lugarSeleccionado,
    RouteInfo? rutaActiva,
    bool clearLugarSeleccionado = false,
    bool clearRuta = false,
  }) {
    return MapLoaded(
      currentCenter: currentCenter ?? this.currentCenter,
      miUbicacion: miUbicacion ?? this.miUbicacion,
      todosLugares: todosLugares ?? this.todosLugares,
      lugaresEnZona: lugaresEnZona ?? this.lugaresEnZona,
      radioKm: radioKm ?? this.radioKm,
      locationObtained: locationObtained ?? this.locationObtained,
      resultadosBusqueda: resultadosBusqueda ?? this.resultadosBusqueda,
      buscando: buscando ?? this.buscando,
      lugarSeleccionado:
          clearLugarSeleccionado ? null : lugarSeleccionado ?? this.lugarSeleccionado,
      rutaActiva: clearRuta ? null : rutaActiva ?? this.rutaActiva,
    );
  }

  @override
  List<Object?> get props => [
        currentCenter,
        miUbicacion,
        todosLugares,
        lugaresEnZona,
        radioKm,
        locationObtained,
        resultadosBusqueda,
        buscando,
        lugarSeleccionado,
        rutaActiva,
      ];
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);
  @override
  List<Object?> get props => [message];
}