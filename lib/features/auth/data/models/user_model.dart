import '../../domain/entities/user.dart';

/// Modelo de Usuario para la capa de datos.
/// Extiende la entidad User y agrega métodos de serialización/deserialización
/// para comunicación con Supabase.
class UserModel extends User {
  UserModel({
    required super.id,
    required super.nombres,
    required super.apellidos,
    required super.nombreUsuario,
    required super.email,
    required super.rol,
  });

  /// Convierte un JSON de Supabase a un objeto UserModel.
  /// Los nombres de los campos deben coincidir con la tabla 'perfiles' en Supabase.
  /// Retorna una instancia de UserModel con los datos mapeados.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_usuario']?.toString() ?? '',
      nombres: json['nombres']?.toString() ?? '',
      apellidos: json['apellidos']?.toString() ?? '',
      nombreUsuario: json['nombre_usuario']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      rol: json['rol']?.toString() ?? 'user',
    );
  }

  /// Convierte un UserModel a JSON para operaciones de UPDATE o INSERT en Supabase.
  /// El campo email no se incluye para evitar que sea editable en la tabla perfiles.
  Map<String, dynamic> toJson() {
    return {
      'id_usuario': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'nombre_usuario': nombreUsuario,
      'rol': rol,
    };
  }

  /// Convierte una entidad User a UserModel.
  /// Útil en el RepositoryImpl para transformar entidades de dominio a modelos de datos.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      nombres: user.nombres,
      apellidos: user.apellidos,
      nombreUsuario: user.nombreUsuario,
      email: user.email,
      rol: user.rol,
    );
  }
}