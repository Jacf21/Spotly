import 'package:spotly/features/posts/data/datasources/feed_remote_datasource.dart';
import 'package:spotly/features/posts/data/models/feed_item_model.dart';

class FeedRepository {
  final FeedRemoteDatasource datasource;

  FeedRepository(this.datasource);

  Future<List<FeedItemModel>> getFeed({
    required String userId,
    required double lat,
    required double lng,
    String? lastCreatedAt,
  }) async {
    final data = await datasource.getFeed(
      userId: userId,
      lat: lat,
      lng: lng,
      lastCreatedAt: lastCreatedAt,
    );

    return data
        .map<FeedItemModel>((json) => FeedItemModel.fromJson(json))
        .toList();
  }
}