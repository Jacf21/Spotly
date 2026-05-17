import '../entities/profile_entity.dart';
import 'package:image_picker/image_picker.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile(String userId);
  Future<void> updateProfile(ProfileEntity profile);
  Future<String> uploadAvatar(String userId, XFile file);
}
