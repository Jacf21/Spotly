import 'package:latlong2/latlong.dart';

class MapLugarModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? resumen;
  final String? fotoPortadaUrl;
  final bool esVerificado;
  final bool esDestacado;
  final String categoria;
  final String departamento;
  final LatLng coordenadas;

  const MapLugarModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.resumen,
    this.fotoPortadaUrl,
    required this.esVerificado,
    required this.esDestacado,
    required this.categoria,
    required this.departamento,
    required this.coordenadas,
  });

  factory MapLugarModel.fromJson(Map<String, dynamic> j) {
    final lat = (j['latitud'] as num).toDouble();
    final lng = (j['longitud'] as num).toDouble();

    // Soporta tanto join anidado como campo plano
    final categoriaNombre = j['categorias'] is Map
        ? (j['categorias'] as Map)['nombre_categoria'] as String? ?? ''
        : j['nombre_categoria'] as String? ?? '';

    final deptoNombre = j['departamentos'] is Map
        ? (j['departamentos'] as Map)['nombre_departamento'] as String? ?? ''
        : j['nombre_departamento'] as String? ?? '';

    return MapLugarModel(
      id: (j['id_lugar'] as num).toInt(),
      nombre: j['nombre_lugar'] as String? ?? '',
      descripcion: j['descripcion'] as String?,
      resumen: j['resumen'] as String?,
      fotoPortadaUrl: j['foto_portada_url'] as String?,
      esVerificado: j['es_verificado'] as bool? ?? false,
      esDestacado: j['es_destacado'] as bool? ?? false,
      categoria: categoriaNombre,
      departamento: deptoNombre,
      coordenadas: LatLng(lat, lng),
    );
  }
}