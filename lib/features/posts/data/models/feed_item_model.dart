class FeedItemModel {
  final int id;
  final String? descripcion;
  final String mediaUrl;
  final String tipo;
  final String lugar;
  final String usuario;
  final String avatar;
  final DateTime createdAt;

  FeedItemModel({
    required this.id,
    this.descripcion,
    required this.mediaUrl,
    required this.tipo,
    required this.lugar,
    required this.usuario,
    required this.avatar,
    required this.createdAt,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: json['id_publicacion'],
      descripcion: json['descripcion_experiencia'],
      mediaUrl: json['media_url'] ?? '',        // ✅ corregido
      tipo: json['tipo_recurso'] ?? 'foto',
      lugar: json['nombre_lugar'] ?? '',
      usuario: json['nombre_usuario'] ?? '',
      avatar: json['foto_perfil_url'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}