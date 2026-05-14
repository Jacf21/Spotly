import 'package:supabase_flutter/supabase_flutter.dart';

class FollowersRemoteDatasource {
  final SupabaseClient client;

  FollowersRemoteDatasource(this.client);

  // ==========================
  // SEGUIR USUARIO
  // ==========================
  Future<void> followUser({
  required String seguidorId,
  required String seguidoId,
}) async {

  await client.from('seguidores').insert({
    'id_usuario_seguidor': seguidorId,
    'id_usuario_seguido': seguidoId,
  });

 
  await client.from('notificaciones').insert({
    'id_usuario_destino': seguidoId,
    'id_usuario_actor': seguidorId,
    'tipo': 'follow',
    'contenido': 'comenzó a seguirte 👤',
  });
}

  // ==========================
  // DEJAR DE SEGUIR
  // ==========================
  Future<void> unfollowUser({
    required String seguidorId,
    required String seguidoId,
  }) async {
    await client
        .from('seguidores')
        .delete()
        .eq('id_usuario_seguidor', seguidorId)
        .eq('id_usuario_seguido', seguidoId);
  }

  // ==========================
  // VERIFICAR SI YA SIGUE
  // ==========================
  Future<bool> isFollowing({
    required String seguidorId,
    required String seguidoId,
  }) async {
    final response = await client
        .from('seguidores')
        .select()
        .eq('id_usuario_seguidor', seguidorId)
        .eq('id_usuario_seguido', seguidoId)
        .maybeSingle();

    return response != null;
  }

  // ==========================
  // CONTAR SEGUIDORES
  // ==========================
  Future<int> getFollowersCount(String userId) async {
    final response = await client
        .from('seguidores')
        .select()
        .eq('id_usuario_seguido', userId);

    return response.length;
  }

  // ==========================
  // CONTAR SEGUIDOS
  // ==========================
  Future<int> getFollowingCount(String userId) async {
    final response = await client
        .from('seguidores')
        .select()
        .eq('id_usuario_seguidor', userId);

    return response.length;
  }
}