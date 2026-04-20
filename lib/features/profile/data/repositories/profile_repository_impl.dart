import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

// RUTA CORREGIDA según tu CMD:
import '../../../auth/data/models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> getProfile(String userId) async {
    // Obtenemos el modelo desde el DataSource
    final model = await remoteDataSource.getProfile(userId);

    // Como UserModel hereda de User, lo retornamos directamente
    return model;
  }

  @override
  Future<void> updateProfile(User user) async {
    // Convertimos la entidad User a UserModel para usar sus métodos de datos
    final model = UserModel(
      id: user.id,
      email: user.email,
      nombres: user.nombres,
      apellidos: user.apellidos,
      nombreUsuario: user.nombreUsuario,
      rol: user.rol,
    );

    await remoteDataSource.updateProfile(model);
  }
}
