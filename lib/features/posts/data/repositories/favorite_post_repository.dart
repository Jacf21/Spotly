import '../datasources/favorite_post_remote_datasource.dart';
import '../models/feed_item_model.dart';

class FavoritePostRepository {
  final FavoritePostRemoteDatasource remoteDatasource;

  FavoritePostRepository(
    this.remoteDatasource,
  );

  Future<List<FeedItemModel>> getFavorites(
    String userId,
  ) {
    return remoteDatasource.getFavorites(
      userId,
    );
  }
}