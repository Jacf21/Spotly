import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:spotly/features/destinations/domain/repositories/post_repository_Pu.dart';
import '../datasources/subida_storage.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
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
  }) async {
    return await remoteDataSource.uploadPost(
      imageFile: image, 
      title: title,
      description: description,
      city: city,
      deptoId: deptoId,
      lat: lat,
      lng: lng,
      privacidad: privacidad,
      permiteComen: permiteComen,
    );
  }
}