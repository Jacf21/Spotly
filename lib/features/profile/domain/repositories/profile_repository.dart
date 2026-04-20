import '../../../auth/domain/entities/user.dart'; // Importa tu clase User

abstract class ProfileRepository {
  // Antes decía Future<ProfileEntity>, cámbialo a Future<User>
  Future<User> getProfile(String userId);

  // Antes recibía ProfileEntity, ahora recibe User
  Future<void> updateProfile(User user);
}
