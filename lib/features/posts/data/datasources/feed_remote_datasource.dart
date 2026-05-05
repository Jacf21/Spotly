import 'package:supabase_flutter/supabase_flutter.dart';

class FeedRemoteDatasource {
  final SupabaseClient client;

  FeedRemoteDatasource(this.client);

  Future<List<dynamic>> getFeed({
    required String userId,
    required double lat,
    required double lng,
    String? lastCreatedAt,
  }) async {
    final response = await client.rpc('get_feed_paginated', params: {
      'user_uuid': userId,
      'user_lat': lat,
      'user_lng': lng,
      'last_created_at': lastCreatedAt,
      'limit_count': 20,
    });
    return response;
  }

  Future<int> getCommentCount(int postId) async {
    final response = await client
        .from('comentarios')
        .select('id_comentario')
        .eq('id_publicacion', postId);
    return response.length;
  }

  Future<List<dynamic>> getPostsByUser(
      String userId, String currentUserId) async {
    final response = await client.rpc('get_user_posts_paginated', params: {
      'user_uuid': currentUserId,
      'target_user_uuid': userId,
      'last_created_at': null,
      'limit_count': 20,
    });
    return response;
  }
}
