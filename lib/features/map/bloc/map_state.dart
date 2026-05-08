import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/map_lugar_model.dart';

// Resultado unificado de búsqueda: puede ser un lugar de Supabase o un resultado de geocoding
class SearchResult {
  final String titulo;
  final String? subtitulo;
  final LatLng coordenadas;
  final bool esLugarRegistrado;
  final MapLugarModel? lugar; // solo si esLugarRegistrado == true

  const SearchResult({
    required this.titulo,
    this.subtitulo,
    required this.coordenadas,
    required this.esLugarRegistrado,
    this.lugar,
  });
}

abstract class MapState extends Equatable {
  const MapState();
  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final LatLng currentCenter;
  final List<MapLugarModel> todosLugares;
  final List<MapLugarModel> lugaresEnZona;
  final double radioKm;
  final bool locationObtained;
  final List<SearchResult> resultadosBusqueda;
  final bool buscando;

  const MapLoaded({
    required this.currentCenter,
    required this.todosLugares,
    required this.lugaresEnZona,
    required this.radioKm,
    required this.locationObtained,
    this.resultadosBusqueda = const [],
    this.buscando = false,
  });

  MapLoaded copyWith({
    LatLng? currentCenter,
    List<MapLugarModel>? todosLugares,
    List<MapLugarModel>? lugaresEnZona,
    double? radioKm,
    bool? locationObtained,
    List<SearchResult>? resultadosBusqueda,
    bool? buscando,
  }) {
    return MapLoaded(
      currentCenter: currentCenter ?? this.currentCenter,
      todosLugares: todosLugares ?? this.todosLugares,
      lugaresEnZona: lugaresEnZona ?? this.lugaresEnZona,
      radioKm: radioKm ?? this.radioKm,
      locationObtained: locationObtained ?? this.locationObtained,
      resultadosBusqueda: resultadosBusqueda ?? this.resultadosBusqueda,
      buscando: buscando ?? this.buscando,
    );
  }

  @override
  List<Object?> get props => [
        currentCenter,
        todosLugares,
        lugaresEnZona,
        radioKm,
        locationObtained,
        resultadosBusqueda,
        buscando,
      ];
}

class MapError extends MapState {
  final String message;
  const MapError(this.message);
  @override
  List<Object?> get props => [message];
}