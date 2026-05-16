import 'package:spotly/features/profile/domain/entities/profile_entity.dart';
import 'package:spotly/features/profile/domain/repositories/profile_repository.dart';
import 'package:spotly/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:spotly/features/profile/data/models/profile_model.dart';
import 'package:image_picker/image_picker.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    // 1. Obtenemos el ProfileModel (Data)
    final model = await remoteDataSource.getProfile(userId);

    // 2. Retornamos la ProfileEntity (Domain) mapeando los campos
    return ProfileEntity(
      id: model.idUsuario,
      email: model.email,
      nombres: model.nombres,
      apellidos: model.apellidos,
      username: model.nombreUsuario,
      bio: model.biografia,
      photoUrl: model.fotoPerfilUrl,
      genero: model.genero,
      fechaNacimiento: model.fechaNacimiento,
      pais: model.paisOrigen,
      ciudad: model.ciudadOrigen,
    );
  }

  @override
  Future<String> uploadAvatar(String userId, XFile file) async {
    return await remoteDataSource.uploadAvatar(userId, file);
  }

  @override
  Future<void> updateProfile(ProfileEntity profile) async {
    // 3. Convertimos la entidad de vuelta al modelo para la base de datos
    final model = ProfileModel(
      idUsuario: profile.id,
      email: profile.email,
      nombres: profile.nombres,
      apellidos: profile.apellidos,
      nombreUsuario: profile.username,
      biografia: profile.bio,
      fotoPerfilUrl: profile.photoUrl,
      genero: profile.genero,
      fechaNacimiento: profile.fechaNacimiento,
      paisOrigen: profile.pais,
      ciudadOrigen: profile.ciudad,
    );

    // 4. Enviamos el modelo al DataSource
    await remoteDataSource.updateProfile(model);
  }
}
