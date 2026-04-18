import '../datasources/post_interaction_remote_datasource.dart';
import '../models/feed_item_model.dart';

class PostInteractionRepository {
  final PostInteractionRemoteDatasource datasource;

  PostInteractionRepository(this.datasource);

  /// [wasLiked] = estado ANTES del toggle optimista en UI
  Future<void> toggleLike({
    required FeedItemModel post,
    required String userId,
    required bool wasLiked,
  }) async {
    if (wasLiked) {
      await datasource.unlikePost(post.id, userId);
    } else {
      await datasource.likePost(post.id, userId);
    }
  }

  /// [wasSaved] = estado ANTES del toggle optimista en UI
  Future<void> toggleSave({
    required FeedItemModel post,
    required String userId,
    required bool wasSaved,
  }) async {
    if (wasSaved) {
      await datasource.unsavePost(post.id, userId);
    } else {
      await datasource.savePost(post.id, userId);
    }
  }
}