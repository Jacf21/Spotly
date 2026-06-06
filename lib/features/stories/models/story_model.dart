class StoryModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String username;
  final String avatarUrl;
  final DateTime createdAt;
  // Lista de usuarios que han visto la historia (relación BD)
  final List<Map<String, dynamic>> viewedBy;

  StoryModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.username,
    required this.avatarUrl,
    required this.createdAt,
    required this.viewedBy,
  });

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      id: map['id'].toString(),
      // ID del usuario propietario de la historia
      userId: map['id_usuario'].toString(),
      imageUrl: map['imagen_url'] ?? '',

      // Datos vienen de relación con tabla perfiles (JOIN en Supabase)
      username: map['perfiles']?['nombre_usuario'] ?? '',
      avatarUrl: map['perfiles']?['foto_perfil_url'] ?? '',

            // Convierte string ISO de BD a DateTime usable en Flutter
      createdAt: DateTime.parse(map['created_at']),
      // Validación importante:
      // Si la relación no viene como lista → evita crash y devuelve []
      viewedBy: (map['historias_vistas'] is List)
          ? List<Map<String, dynamic>>.from(map['historias_vistas'])
          : [],
    );
  }
}