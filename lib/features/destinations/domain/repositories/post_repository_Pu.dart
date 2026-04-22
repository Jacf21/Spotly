import 'package:image_picker/image_picker.dart';
abstract class PostRepository {
  Future<void> createPost({
    required XFile image,
    required String title,
    required String description,
    required String city,
    required int deptoId,
    required double lat,
    required double lng,
    required String privacidad,
    required bool permiteComen,
  });
}