import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.nombres,
    required super.apellidos,
    required super.nombreUsuario,
    required super.email,
    required super.rol,
  });

  /// 📥 De JSON (Supabase) a Modelo
  /// Asegúrate de que estos nombres coincidan con tu tabla en Supabase
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

  /// 📤 De Modelo a JSON (Para hacer el UPDATE o INSERT)
  Map<String, dynamic> toJson() {
    return {
      'id_usuario': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'nombre_usuario': nombreUsuario,
      // No incluimos el email si no quieres que sea editable en la tabla perfiles
      'rol': rol,
    };
  }

  /// 🔄 Utilidad: Convertir una Entidad User a UserModel
  /// Esto te ahorrará mucho código en el RepositoryImpl
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
