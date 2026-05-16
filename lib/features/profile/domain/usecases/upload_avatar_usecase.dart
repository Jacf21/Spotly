import 'package:image_picker/image_picker.dart';
import '../repositories/profile_repository.dart';

class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  Future<String> execute(String userId, XFile file) async {
    return await repository.uploadAvatar(userId, file);
  }
}