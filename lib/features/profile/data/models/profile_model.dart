class ProfileModel {
  final String idUsuario;
  final String email;
  final String nombres;
  final String apellidos;
  final String nombreUsuario;
  final String? biografia;
  final String? fotoPerfilUrl;

  ProfileModel({
    required this.idUsuario,
    required this.email,
    required this.nombres,
    required this.apellidos,
    required this.nombreUsuario,
    this.biografia,
    this.fotoPerfilUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      idUsuario: json['id_usuario'] ?? '',
      email: json['email'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      nombreUsuario: json['nombre_usuario'] ?? '',
      biografia: json['biografia'],
      fotoPerfilUrl: json['foto_perfil_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'email': email,
      'nombres': nombres,
      'apellidos': apellidos,
      'nombre_usuario': nombreUsuario,
      'biografia': biografia,
      'foto_perfil_url': fotoPerfilUrl,
    };
  }
}
