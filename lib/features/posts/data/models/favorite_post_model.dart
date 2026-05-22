class FavoritePostModel {
  final int id;
  final String userId;
  final String? descripcion;
  final String mediaUrl;
  final String tipo;
  final String lugar;
  final String usuario;
  final String avatar;
  final DateTime createdAt;
  final bool isLiked;
  final int likesCount;
  final int comentarioCount;
  final bool comentarioActivado;
  final String visiblePara;
  final int? lugarId;

  FavoritePostModel({
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
    required this.likesCount,
    required this.comentarioCount,
    required this.comentarioActivado,
    required this.visiblePara,
    required this.lugarId,
  });

  factory FavoritePostModel.fromMap(
    Map<String, dynamic> json,
  ) {
    return FavoritePostModel(
      id: (json['id_publicacion'] as num).toInt(),

      userId:
          json['id_usuario'] as String? ?? '',

      descripcion:
          json['descripcion_experiencia']
              as String?,

      mediaUrl:
          json['media_url'] as String? ?? '',

      tipo:
          json['tipo_recurso'] as String? ??
              'foto',

      lugar:
          json['nombre_lugar'] as String? ??
              '',

      usuario:
          json['nombre_usuario'] as String? ??
              '',

      avatar:
          json['foto_perfil_url'] as String? ??
              '',

      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),

      isLiked:
          json['is_liked'] as bool? ?? false,

      likesCount: int.tryParse(
            json['likes_count'].toString(),
          ) ??
          0,

      comentarioCount: int.tryParse(
            json['comentario_count']
                .toString(),
          ) ??
          0,

      comentarioActivado:
          json['comentario_activado']
                  as bool? ??
              true,

      visiblePara:
          json['visible_para'] as String? ??
              'public',

      lugarId:
          (json['id_lugar'] as num?)
              ?.toInt(),
    );
  }
}