import '../../../auth/domain/entities/user.dart'; // Importa User
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  // CORRECCIÓN: Cambia ProfileEntity por User
  Future<void> execute(User user) async {
    return await repository.updateProfile(user);
  }
}
