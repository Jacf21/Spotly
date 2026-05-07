class LugarPostModel {
  final int id;
  final String userId; // ← NUEVO
  final String usuario;
  final String avatar;
  final String descripcion;
  final String mediaUrl;
  final DateTime createdAt;
  final int likesCount;
  final int comentarioCount;
  final bool isLiked;

  LugarPostModel({
    required this.id,
    required this.userId, // ← NUEVO
    required this.usuario,
    required this.avatar,
    required this.descripcion,
    required this.mediaUrl,
    required this.createdAt,
    required this.likesCount,
    required this.comentarioCount,
    required this.isLiked,
  });

  factory LugarPostModel.fromJson(Map<String, dynamic> json) {
    return LugarPostModel(
      id: (json['id_publicacion'] as num).toInt(),
      userId: json['id_usuario'] as String? ?? '', // ← NUEVO
      usuario: json['nombre_usuario'] as String? ?? '',
      avatar: json['foto_perfil_url'] as String? ?? '',
      descripcion: json['descripcion_experiencia'] as String? ?? '',
      mediaUrl: json['media_url'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      comentarioCount: (json['comentario_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }
}
