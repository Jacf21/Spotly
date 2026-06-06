import 'package:latlong2/latlong.dart';

class LugarDetalleModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? resumen;
  final String? direccion;
  final int? alturaMsnm;
  final String? climaRecomendado;
  final String? mejorEpocaVisitar;
  final String? informacionUtil;
  final String? fotoPortadaUrl;
  final bool esVerificado;
  final bool esDestacado;
  final int likeCount;
  final String categoria;
  final String departamento;
  final LatLng? coordenadas;
  final int? idCategoria;

  const LugarDetalleModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.resumen,
    this.direccion,
    this.alturaMsnm,
    this.climaRecomendado,
    this.mejorEpocaVisitar,
    this.informacionUtil,
    this.fotoPortadaUrl,
    required this.esVerificado,
    required this.esDestacado,
    required this.likeCount,
    required this.categoria,
    required this.departamento,
    this.coordenadas,
    this.idCategoria,
  });

  factory LugarDetalleModel.fromJson(Map<String, dynamic> j) {
   // Latitud y longitud vienen separadas desde la BD
    // Solo se crea LatLng si ambos valores existen
    final lat = (j['latitud'] as num?)?.toDouble();
    final lng = (j['longitud'] as num?)?.toDouble();

    return LugarDetalleModel(
      id:                (j['id_lugar'] as num).toInt(),
      nombre:            j['nombre_lugar']       as String? ?? '',
       // Campos opcionales de información del lugar
      descripcion:       j['descripcion']         as String?,
      resumen:           j['resumen']             as String?,
      direccion:         j['direccion']           as String?,
      alturaMsnm:        j['altura_msnm']         as int?,
      climaRecomendado:  j['clima_recomendado']   as String?,
      mejorEpocaVisitar: j['mejor_epoca_visitar'] as String?,
      informacionUtil:   j['informacion_util']    as String?,
      fotoPortadaUrl:    j['foto_portada_url']    as String?,
      // Flags importantes de estado del lugar
      esVerificado:      j['es_verificado']       as bool? ?? false,
      esDestacado:       j['es_destacado']        as bool? ?? false,
      likeCount:         (j['like_count'] as num?)?.toInt() ?? 0,
      categoria:         j['categoria']    as String? ?? '',
      departamento:      j['departamento'] as String? ?? '',
      // Coordenadas opcionales (null si el lugar no tiene mapa)
      coordenadas: (lat != null && lng != null) ? LatLng(lat, lng) : null,
      idCategoria: j['id_categoria'] as int?,
    );
  }
}