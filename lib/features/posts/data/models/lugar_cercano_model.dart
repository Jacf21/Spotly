class LugarCercanoModel {
  final int id;
  final String nombre;
  final double distanciaM;
  final String? fotoUrl;
  final String categoria;

  const LugarCercanoModel({
    required this.id,
    required this.nombre,
    required this.distanciaM,
    this.fotoUrl,
    required this.categoria,
  });

  factory LugarCercanoModel.fromJson(Map<String, dynamic> j) {
    return LugarCercanoModel(
      id:          (j['id_lugar'] as num).toInt(),
      nombre:      j['nombre_lugar'] as String? ?? '',
      distanciaM:  (j['distancia_m'] as num).toDouble(),
      fotoUrl:     j['foto_portada_url'] as String?,
      categoria:   j['nombre_categoria'] as String? ?? '',
    );
  }
}