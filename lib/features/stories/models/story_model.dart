class StoryModel {
  final String id;
  final String userId;
  final String imageUrl;
  final String username;
  final String avatarUrl;
  final DateTime createdAt;
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
      userId: map['id_usuario'].toString(),
      imageUrl: map['imagen_url'] ?? '',

      // 🔥 AQUÍ ESTÁ EL FIX REAL
      username: map['perfiles']?['nombre_usuario'] ?? '',
      avatarUrl: map['perfiles']?['foto_perfil_url'] ?? '',

      createdAt: DateTime.parse(map['created_at']),
      viewedBy: (map['historias_vistas'] is List)
          ? List<Map<String, dynamic>>.from(map['historias_vistas'])
          : [],
    );
  }
}