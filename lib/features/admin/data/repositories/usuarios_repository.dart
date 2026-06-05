import '../datasources/usuarios_datasource.dart';
import '../models/admin_usuario_model.dart';

class UsuariosRepository {
  final UsuariosDatasource _ds;
  UsuariosRepository(this._ds);

  /// Obtener todos los usuarios
  Future<List<AdminUsuarioModel>> getUsuarios() async {
    final data = await _ds.fetchUsuarios();
    return data.map(AdminUsuarioModel.fromJson).toList();
  }

  /// Funcion para banear usuario
  Future<void> banearUsuario({
    required String userId,
    required String tipoBan,
    required String? motivoBan,
  }) => _ds.banearUsuario(
        userId: userId,
        tipoBan: tipoBan,
        motivoBan: motivoBan,
      );

  /// Funcion para quitar baneo de un usuario
  Future<void> desbanearUsuario(String userId) =>
      _ds.desbanearUsuario(userId);
}