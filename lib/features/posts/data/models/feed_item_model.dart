class FeedItemModel {
  final int id;
  final String userId;
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

  // Campos de interacción
  bool isLiked;
  bool isSaved;
  int likesCount;
  int comentarioCount;

  // 🆕 CAMPOS PARA PUBLICACIONES COMPARTIDAS
  final bool isShared;
  final int? originalPostId;
  final String? originalUserId;
  final String? originalUserName;
  final String? sharedByUserId;
  final DateTime? sharedAt;

  FeedItemModel({
    required this.id,
    required this.userId,
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
    this.isShared = false,
    this.originalPostId,
    this.originalUserId,
    this.originalUserName,
    this.sharedByUserId,
    this.sharedAt,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: (json['id_publicacion'] as num).toInt(),
      userId: json['id_usuario'] as String? ?? '',
      descripcion: json['descripcion_experiencia'] as String?,
      // CORREGIDO: soporta tanto 'url_recurso' como 'media_url'
mediaUrl: json['media_url'] as String? ?? json['url_recurso'] as String? ?? '',      tipo: json['tipo_recurso'] as String? ?? 'foto',
      // CORREGIDO: usa 'nombre_lugar' que devuelve la RPC
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
      isShared: json['es_compartido'] as bool? ?? false,
      originalPostId: (json['id_publicacion_original'] as num?)?.toInt(),
      originalUserId: json['id_usuario_original'] as String?,
      originalUserName: json['nombre_usuario_original'] as String?,
      sharedByUserId: json['id_usuario_que_comparte'] as String?,
      sharedAt: json['fecha_compartido'] != null
          ? DateTime.tryParse(json['fecha_compartido'] as String)
          : null,
    );
  }

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
    bool? isShared,
    int? originalPostId,
    String? originalUserId,
    String? originalUserName,
    String? sharedByUserId,
    DateTime? sharedAt,
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
      isShared: isShared ?? this.isShared,
      originalPostId: originalPostId ?? this.originalPostId,
      originalUserId: originalUserId ?? this.originalUserId,
      originalUserName: originalUserName ?? this.originalUserName,
      sharedByUserId: sharedByUserId ?? this.sharedByUserId,
      sharedAt: sharedAt ?? this.sharedAt,
    );
  }
}