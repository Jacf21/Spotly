class AdminLugarModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? resumen;
  final String? fotoPortadaUrl;
  final bool esVerificado;
  final bool esDestacado;
  final int likeCount;
  final int publicacionesCount;
  final int? idCategoria;
  final String categoria;
  final String departamento;
  final DateTime createdAt;

  const AdminLugarModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.resumen,
    this.fotoPortadaUrl,
    required this.esVerificado,
    required this.esDestacado,
    required this.likeCount,
    required this.publicacionesCount,
    this.idCategoria,
    required this.categoria,
    required this.departamento,
    required this.createdAt,
  });

  factory AdminLugarModel.fromJson(Map<String, dynamic> j) {
    final cat = j['categorias'] as Map?;
    final dep = j['departamentos'] as Map?;
    return AdminLugarModel(
      id:                  (j['id_lugar'] as num).toInt(),
      nombre:              j['nombre_lugar']     as String? ?? '',
      descripcion:         j['descripcion']       as String?,
      resumen:             j['resumen']           as String?,
      fotoPortadaUrl:      j['foto_portada_url']  as String?,
      esVerificado:        j['es_verificado']     as bool? ?? false,
      esDestacado:         j['es_destacado']      as bool? ?? false,
      likeCount:           (j['like_count'] as num?)?.toInt() ?? 0,
      publicacionesCount:  (j['publicaciones_count'] as num?)?.toInt() ?? 0,
      idCategoria:         (cat?['id_categoria'] as num?)?.toInt(),
      categoria:           cat?['nombre_categoria'] as String? ?? 'Sin categoría',
      departamento:        dep?['nombre_departamento'] as String? ?? '',
      createdAt:           DateTime.parse(j['created_at'] as String),
    );
  }
}