import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/feed_item_model.dart';

class FavoritePostRemoteDatasource {
  final SupabaseClient client;

  FavoritePostRemoteDatasource(this.client);

  Future<List<FeedItemModel>> getFavorites(
    String userId,
  ) async {

    // Obtener IDs favoritos
    final favoritesResponse = await client
        .from('favoritos')
        .select('id_publicacion')
        .eq('id_usuario', userId);

    if (favoritesResponse.isEmpty) {
      return [];
    }

    final favoriteIds = favoritesResponse
        .map<int>(
          (e) => e['id_publicacion'] as int,
        )
        .toList();

    // Obtener feed real
    final feedResponse = await client.rpc(
      'get_feed_paginated',
      params: {
        'user_uuid': userId,
        'user_lat': -16.5,
        'user_lng': -68.15,
        'last_created_at': null,
        'limit_count': 100,
      },
    );

    // Filtrar solo favoritos
    final filtered = feedResponse.where(
      (post) =>
          favoriteIds.contains(
            post['id_publicacion'],
          ),
    );

    return filtered
        .map<FeedItemModel>(
          (json) => FeedItemModel.fromJson(json),
        )
        .toList();
  }
}