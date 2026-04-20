// 1. IMPORTANTE: Cambiamos a la entidad User que es la que estamos usando en todo el proyecto
import '../../../auth/domain/entities/user.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  // 1. El retorno ahora es Future<User>
  // 2. Mantenemos el nombre 'execute' si es el que usa tu Bloc,
  // pero llamamos a repository.getProfile internamente.
  Future<User> execute(String userId) {
    return repository.getProfile(userId);
  }
}
