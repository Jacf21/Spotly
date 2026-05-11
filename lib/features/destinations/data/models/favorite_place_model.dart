class FavoritePlaceModel {
  final int id;
  final String nombre;
  final String? fotoPortadaUrl;
  final int? idCategoria;
  final int? idDepartamento;
  final bool esVerificado;

  // 👇 NUEVO: campos para UI
  final String categoria;
  final String departamento;

  FavoritePlaceModel({
    required this.id,
    required this.nombre,
    required this.fotoPortadaUrl,
    required this.idCategoria,
    required this.idDepartamento,
    required this.esVerificado,
    required this.categoria,
    required this.departamento,
  });

  factory FavoritePlaceModel.fromMap(Map<String, dynamic> map) {
    return FavoritePlaceModel(
      id: map['id_lugar'] ?? 0,
      nombre: map['nombre_lugar'] ?? '',
      fotoPortadaUrl: map['foto_portada_url'],

      idCategoria: map['id_categoria'],
      idDepartamento: map['id_departamento'],

      esVerificado: map['es_verificado'] ?? false,

      // 🔥 UI SAFE VALUES
      categoria: map['categoria_nombre'] ?? '',
      departamento: map['departamento_nombre'] ?? '',
    );
  }
}