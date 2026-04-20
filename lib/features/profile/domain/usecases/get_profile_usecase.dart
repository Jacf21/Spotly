// 1. CAMBIO CRUCIAL: Importamos la entidad de Perfil, no la de Auth
import 'package:spotly/features/profile/domain/entities/profile_entity.dart';
import 'package:spotly/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  // 2. El retorno ahora debe ser Future<ProfileEntity> para que coincida con el Repo
  Future<ProfileEntity> execute(String userId) {
    return repository.getProfile(userId);
  }
}
