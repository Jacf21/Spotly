import 'package:spotly/features/profile/domain/entities/profile_entity.dart';
import 'package:spotly/features/profile/domain/repositories/profile_repository.dart';
import 'package:spotly/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:spotly/features/profile/data/models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    // Obtenemos el modelo desde el DataSource
    final model = await remoteDataSource.getProfile(userId);

    // Mapeamos el modelo a la entidad para que el dominio lo entienda
    return ProfileEntity(
      id: model.idUsuario, // Usando los campos de tu ProfileModel
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
  Future<void> updateProfile(ProfileEntity profile) async {
    // Convertimos la entidad de vuelta a ProfileModel para enviarla a Supabase
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

    await remoteDataSource.updateProfile(model);
  }
}
