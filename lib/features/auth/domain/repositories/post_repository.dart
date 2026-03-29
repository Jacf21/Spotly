import 'dart:io';

abstract class PostRepository {
  Future<void> createPost({
    required File image,
    required String title,
    required String description,
    required String city,
    required int deptoId,
    required double lat,
    required double lng,
  });
}