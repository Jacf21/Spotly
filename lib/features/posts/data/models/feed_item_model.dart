class FeedItemModel {
  final int id;
  final String userId; // ← NUEVO: ID del usuario que creó la publicación
  final String? descripcion;
  final String mediaUrl;
  final String tipo;
  final String lugar;
  final String usuario;
  final String avatar;
  final DateTime createdAt;
  final bool comentarioActivado;
  final String visiblePara;
  final int? lugarId;

  // 🆕 NUEVOS CAMPOS
  bool isLiked;
  bool isSaved;
  int likesCount;
  int comentarioCount;

  FeedItemModel({
    required this.id,
    required this.userId, // ← NUEVO: requerido
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
    required this.comentarioActivado,
    required this.visiblePara,
    required this.lugarId,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: (json['id_publicacion'] as num).toInt(),
      userId: json['id_usuario'] as String? ?? '', // ← NUEVO: mapea el campo
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
      comentarioActivado: json['comentario_activado'] as bool? ?? true,
      visiblePara: json['visible_para'] as String? ?? 'public',
      lugarId: (json['id_lugar'] as num?)?.toInt(),
    );
  }

  // Método copyWith opcional
  FeedItemModel copyWith({
    int? id,
    String? userId,
    String? descripcion,
    String? mediaUrl,
    String? tipo,
    String? lugar,
    String? usuario,
    String? avatar,
    DateTime? createdAt,
    bool? isLiked,
    bool? isSaved,
    int? likesCount,
    int? comentarioCount,
    bool? comentarioActivado,
    String? visiblePara,
    int? lugarId,
  }) {
    return FeedItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      descripcion: descripcion ?? this.descripcion,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      tipo: tipo ?? this.tipo,
      lugar: lugar ?? this.lugar,
      usuario: usuario ?? this.usuario,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      likesCount: likesCount ?? this.likesCount,
      comentarioCount: comentarioCount ?? this.comentarioCount,
      comentarioActivado: comentarioActivado ?? this.comentarioActivado,
      visiblePara: visiblePara ?? this.visiblePara,
      lugarId: lugarId ?? this.lugarId,
    );
  }
}
