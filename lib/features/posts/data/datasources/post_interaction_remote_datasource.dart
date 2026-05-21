import 'package:supabase_flutter/supabase_flutter.dart';

class PostInteractionRemoteDatasource {
  final SupabaseClient client;

  PostInteractionRemoteDatasource(this.client);

  Future<void> likePost(int postId, String userId) async {
    await client.from('likes').insert({
      'id_publicacion': postId,
      'id_usuario': userId,
    });
  }

  Future<void> unlikePost(int postId, String userId) async {
    await client
        .from('likes')
        .delete()
        .eq('id_publicacion', postId)
        .eq('id_usuario', userId);
  }

  Future<void> savePost(int postId, String userId) async {
    await client.from('favoritos').insert({
      'id_publicacion': postId,
      'id_usuario': userId,
    });
  }

  Future<void> unsavePost(int postId, String userId) async {
    await client
        .from('favoritos')
        .delete()
        .eq('id_publicacion', postId)
        .eq('id_usuario', userId);
  }
}