class CommentModel {
  final int id;
  final int postId;
  final String userId;
  final String nombreUsuario;
  final String avatarUrl;
  final String texto;
  final DateTime createdAt;
  final int? parentId;
  final String? replyToUserName;
  final int likeCount; // ← nuevo
  final bool isLiked; // ← nuevo (si el usuario actual dio like)

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.nombreUsuario,
    required this.avatarUrl,
    required this.texto,
    required this.createdAt,
    this.parentId,
    this.replyToUserName,
    required this.likeCount,
    required this.isLiked,
  });

  bool get isRoot => parentId == null;
  bool get isReply => parentId != null;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: (json['id_comentario'] as num).toInt(),
      postId: (json['id_publicacion'] as num).toInt(),
      userId: json['id_usuario'] as String,
      nombreUsuario: json['nombre_usuario'] as String? ?? '',
      avatarUrl: json['foto_perfil_url'] as String? ?? '',
      texto: json['texto_comentario'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      parentId:
          json['parent_id'] != null ? (json['parent_id'] as num).toInt() : null,
      replyToUserName: json['reply_to_user_name'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_comentario': id,
      'id_publicacion': postId,
      'id_usuario': userId,
      'nombre_usuario': nombreUsuario,
      'foto_perfil_url': avatarUrl,
      'texto_comentario': texto,
      'created_at': createdAt.toIso8601String(),
      'parent_id': parentId,
      'reply_to_user_name': replyToUserName,
      'like_count': likeCount,
    };
  }

  CommentModel copyWith({
    int? id,
    int? postId,
    String? userId,
    String? nombreUsuario,
    String? avatarUrl,
    String? texto,
    DateTime? createdAt,
    int? parentId,
    String? replyToUserName,
    int? likeCount,
    bool? isLiked,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      texto: texto ?? this.texto,
      createdAt: createdAt ?? this.createdAt,
      parentId: parentId ?? this.parentId,
      replyToUserName: replyToUserName ?? this.replyToUserName,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommentModel &&
        other.id == id &&
        other.postId == postId &&
        other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(id, postId, userId);
}
