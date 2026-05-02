class LugarPostModel {
  final int id;
  final String? descripcion;
  final String mediaUrl;
  final String usuario;
  final String avatar;
  final DateTime createdAt;
  bool isLiked;
  int likesCount;
  int comentarioCount;

  LugarPostModel({
    required this.id,
    this.descripcion,
    required this.mediaUrl,
    required this.usuario,
    required this.avatar,
    required this.createdAt,
    required this.isLiked,
    required this.likesCount,
    required this.comentarioCount,
  });

  factory LugarPostModel.fromJson(Map<String, dynamic> j) {
    return LugarPostModel(
      id:             (j['id_publicacion'] as num).toInt(),
      descripcion:    j['descripcion_experiencia'] as String?,
      mediaUrl:       j['media_url']       as String? ?? '',
      usuario:        j['nombre_usuario']  as String? ?? '',
      avatar:         j['foto_perfil_url'] as String? ?? '',
      createdAt:      DateTime.parse(j['created_at'] as String),
      isLiked:        j['is_liked']        as bool? ?? false,
      likesCount:     int.tryParse(j['likes_count'].toString()) ?? 0,
      comentarioCount: int.tryParse(j['comentario_count'].toString()) ?? 0,
    );
  }
}