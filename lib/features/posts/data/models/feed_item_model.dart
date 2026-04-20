class FeedItemModel {
  final int id;
  final String? descripcion;
  final String mediaUrl;
  final String tipo;
  final String lugar;
  final String usuario;
  final String avatar;
  final DateTime createdAt;

  // 🆕 NUEVOS CAMPOS
  bool isLiked;
  bool isSaved;
  int likesCount;
  int comentarioCount;

  FeedItemModel({
    required this.id,
    this.descripcion,
    required this.mediaUrl,
    required this.tipo,
    required this.lugar,
    required this.usuario,
    required this.avatar,
    required this.createdAt,

    required this.isLiked,
    required this.isSaved,
    required this.likesCount,
    required this.comentarioCount,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: (json['id_publicacion'] as num).toInt(),
      descripcion: json['descripcion_experiencia'] as String?,
      mediaUrl: json['media_url'] as String? ?? '',
      tipo: json['tipo_recurso'] as String? ?? 'foto',
      lugar: json['nombre_lugar'] as String? ?? '',
      usuario: json['nombre_usuario'] as String? ?? '',
      avatar: json['foto_perfil_url'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      isLiked: json['is_liked'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      
      likesCount: int.tryParse(json['likes_count'].toString()) ?? 0,
      comentarioCount: int.tryParse(json['comentario_count'].toString()) ?? 0,
    );
  }
}