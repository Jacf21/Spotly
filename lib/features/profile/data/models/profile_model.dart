class ProfileModel {
  final String idUsuario;
  final String email;
  final String nombres;
  final String apellidos;
  final String nombreUsuario;
  final String? biografia;
  final String? fotoPerfilUrl;
  final String? genero;
  final String? fechaNacimiento;
  final String? paisOrigen;
  final String? ciudadOrigen;

  ProfileModel({
    required this.idUsuario,
    required this.email,
    required this.nombres,
    required this.apellidos,
    required this.nombreUsuario,
    this.biografia,
    this.fotoPerfilUrl,
    this.genero,
    this.fechaNacimiento,
    this.paisOrigen,
    this.ciudadOrigen,
  });

  // Mapeo de la base de datos (Supabase) al código
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      idUsuario: json['id_usuario'] ?? '',
      email: json['email'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      nombreUsuario: json['nombre_usuario'] ?? '',
      biografia: json['biografia'],
      fotoPerfilUrl: json['foto_perfil_url'],
      genero: json['genero'],
      fechaNacimiento: json['fecha_nacimiento'],
      paisOrigen: json['pais_origen'],
      ciudadOrigen: json['ciudad_origen'],
    );
  }

  // Mapeo del código a la base de datos para actualizar
  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'email': email,
      'nombres': nombres,
      'apellidos': apellidos,
      'nombre_usuario': nombreUsuario,
      'biografia': biografia,
      'foto_perfil_url': fotoPerfilUrl,
      'genero': genero,
      'fecha_nacimiento': fechaNacimiento,
      'pais_origen': paisOrigen,
      'ciudad_origen': ciudadOrigen,
    };
  }
}
