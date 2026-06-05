/// Modelo de datos para el perfil de usuario en la capa de datos.
/// Se encarga de la serialización/deserialización entre la base de datos (Supabase)
/// y la aplicación. Los nombres de los campos deben coincidir con la tabla 'perfiles'.
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

  /// Convierte un JSON de Supabase a un objeto ProfileModel.
  /// Los nombres de los campos deben coincidir con la tabla 'perfiles'.
  /// Retorna una instancia de ProfileModel con los datos mapeados.
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

  /// Convierte un ProfileModel a JSON para operaciones de UPDATE o INSERT en Supabase.
  /// Retorna un Map con los campos listos para enviar a la base de datos.
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