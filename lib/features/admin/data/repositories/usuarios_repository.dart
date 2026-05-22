import '../datasources/usuarios_datasource.dart';
import '../models/admin_usuario_model.dart';

class UsuariosRepository {
  final UsuariosDatasource _ds;
  UsuariosRepository(this._ds);

  Future<List<AdminUsuarioModel>> getUsuarios() async {
    final data = await _ds.fetchUsuarios();
    return data.map(AdminUsuarioModel.fromJson).toList();
  }

  Future<void> banearUsuario({
    required String userId,
    required String tipoBan,
    required String? motivoBan,
  }) => _ds.banearUsuario(
        userId: userId,
        tipoBan: tipoBan,
        motivoBan: motivoBan,
      );

  Future<void> desbanearUsuario(String userId) =>
      _ds.desbanearUsuario(userId);
}