import 'dart:io';
import '../../domain/repositories/post_repository.dart';
import '../datasources/subida_storage.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> createPost({
    required File image,
    required String title,
    required String description,
    required String city,
    required int deptoId,
    required double lat,
    required double lng,
  }) async {
    return await remoteDataSource.uploadPost(
      imageFile: image,
      title: title,
      description: description,
     // city: city,
      deptoId: deptoId,
      lat: lat,
      lng: lng,
    );
  }
}