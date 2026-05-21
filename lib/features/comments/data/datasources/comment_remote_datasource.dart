import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/comment_model.dart';

class CommentRemoteDatasource {
  final SupabaseClient client;
  CommentRemoteDatasource(this.client);

  // Método original (sin likes)
  Future<List<CommentModel>> getComments(int postId) async {
    final response = await client.from('comentarios').select('''
          id_comentario,
          id_publicacion,
          id_usuario,
          texto_comentario,
          created_at,
          parent_id,
          reply_to_user_name,
          like_count,
          perfiles (
            nombre_usuario,
            foto_perfil_url
          )
        ''').eq('id_publicacion', postId).order('created_at', ascending: true);

    return (response as List).map((json) {
      final perfil = json['perfiles'] as Map<String, dynamic>? ?? {};
      return CommentModel.fromJson({
        ...json,
        'nombre_usuario': perfil['nombre_usuario'],
        'foto_perfil_url': perfil['foto_perfil_url'],
        'is_liked': false,
      });
    }).toList();
  }

  // Obtener comentarios con información de likes del usuario actual
  Future<List<CommentModel>> getCommentsWithLikes(
      int postId, String userId) async {
    final response = await client.from('comentarios').select('''
          id_comentario,
          id_publicacion,
          id_usuario,
          texto_comentario,
          created_at,
          parent_id,
          reply_to_user_name,
          like_count,
          perfiles (
            nombre_usuario,
            foto_perfil_url
          )
        ''').eq('id_publicacion', postId).order('created_at', ascending: true);

    final likesResponse = await client
        .from('comment_likes')
        .select('comment_id')
        .eq('user_id', userId);

    final likedCommentIds =
        likesResponse.map((e) => e['comment_id'] as int).toSet();

    return (response as List).map((json) {
      final perfil = json['perfiles'] as Map<String, dynamic>? ?? {};
      final commentId = (json['id_comentario'] as num).toInt();
      return CommentModel.fromJson({
        ...json,
        'nombre_usuario': perfil['nombre_usuario'],
        'foto_perfil_url': perfil['foto_perfil_url'],
        'is_liked': likedCommentIds.contains(commentId),
      });
    }).toList();
  }

  // Agregar comentario o respuesta
  Future<CommentModel> addComment({
    required int postId,
    required String userId,
    required String texto,
    int? parentId,
    String? replyToUserName,
  }) async {
    final Map<String, dynamic> insertData = {
      'id_publicacion': postId,
      'id_usuario': userId,
      'texto_comentario': texto,
      'created_at': DateTime.now().toIso8601String(),
      'like_count': 0,
    };
    if (parentId != null) insertData['parent_id'] = parentId;
    if (replyToUserName != null)
      insertData['reply_to_user_name'] = replyToUserName;

    final response =
        await client.from('comentarios').insert(insertData).select('''
          id_comentario,
          id_publicacion,
          id_usuario,
          texto_comentario,
          created_at,
          parent_id,
          reply_to_user_name,
          like_count,
          perfiles (
            nombre_usuario,
            foto_perfil_url
          )
        ''').single();

    final perfil = response['perfiles'] as Map<String, dynamic>? ?? {};
    return CommentModel.fromJson({
      ...response,
      'nombre_usuario': perfil['nombre_usuario'],
      'foto_perfil_url': perfil['foto_perfil_url'],
      'is_liked': false,
    });
  }

  // Eliminar comentario
  Future<void> deleteComment({
    required int commentId,
    required String userId,
  }) async {
    await client
        .from('comentarios')
        .delete()
        .eq('id_comentario', commentId)
        .eq('id_usuario', userId);
  }

  // Dar o quitar like a un comentario (versión corregida)
  Future<void> toggleLike(int commentId, String userId, bool wasLiked) async {
    if (wasLiked) {
      // Quitar like
      await client
          .from('comment_likes')
          .delete()
          .eq('comment_id', commentId)
          .eq('user_id', userId);
    } else {
      // Agregar like
      await client.from('comment_likes').insert({
        'comment_id': commentId,
        'user_id': userId,
      });
    }

    // Obtener el nuevo contador (contando manualmente)
    final allLikes = await client
        .from('comment_likes')
        .select('comment_id')
        .eq('comment_id', commentId);

    final newCount = allLikes.length;

    // Actualizar el contador en la tabla comentarios
    await client
        .from('comentarios')
        .update({'like_count': newCount}).eq('id_comentario', commentId);
  }
}
