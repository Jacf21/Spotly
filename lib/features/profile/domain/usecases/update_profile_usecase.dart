// 1. IMPORTANTE: Cambiamos el import para usar la entidad de Perfil
import 'package:spotly/features/profile/domain/entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  // 2. CORRECCIÓN: El método ahora recibe un ProfileEntity
  // Esto permite que el repositorio reciba todos los campos (bio, género, etc.)
  Future<void> execute(ProfileEntity profile) async {
    return await repository.updateProfile(profile);
  }
}
