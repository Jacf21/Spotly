class CommentModel {
  final int id;
  final String userId;
  final String nombreUsuario;
  final String avatarUrl;
  final String texto;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.nombreUsuario,
    required this.avatarUrl,
    required this.texto,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: (json['id_comentario'] as num).toInt(),
      userId: json['id_usuario'] as String,
      nombreUsuario: json['nombre_usuario'] as String? ?? '',
      avatarUrl: json['foto_perfil_url'] as String? ?? '',
      texto: json['texto_comentario'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}