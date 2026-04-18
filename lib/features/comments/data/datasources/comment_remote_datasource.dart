import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

class CommentRemoteDatasource {
  final SupabaseClient client;

  CommentRemoteDatasource(this.client);

  Future<List<CommentModel>> getComments(int postId) async {
    final response = await client
        .from('comentarios')
        .select('''
          id_comentario,
          id_usuario,
          texto_comentario,
          created_at,
          perfiles (
            nombre_usuario,
            foto_perfil_url
          )
        ''')
        .eq('id_publicacion', postId)
        .order('created_at', ascending: true);

    return (response as List).map((json) {
      final perfil = json['perfiles'] as Map<String, dynamic>? ?? {};
      return CommentModel.fromJson({
        ...json,
        'nombre_usuario': perfil['nombre_usuario'],
        'foto_perfil_url': perfil['foto_perfil_url'],
      });
    }).toList();
  }

  Future<CommentModel> addComment({
    required int postId,
    required String userId,
    required String texto,
  }) async {
    final response = await client
        .from('comentarios')
        .insert({
          'id_publicacion': postId,
          'id_usuario': userId,
          'texto_comentario': texto,
        })
        .select('''
          id_comentario,
          id_usuario,
          texto_comentario,
          created_at,
          perfiles (
            nombre_usuario,
            foto_perfil_url
          )
        ''')
        .single();

    final perfil = response['perfiles'] as Map<String, dynamic>? ?? {};
    return CommentModel.fromJson({
      ...response,
      'nombre_usuario': perfil['nombre_usuario'],
      'foto_perfil_url': perfil['foto_perfil_url'],
    });
  }

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
}