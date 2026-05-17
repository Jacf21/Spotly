import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/features/destinations/data/models/favorite_place_model.dart';

class LugarRemoteDatasource {
  final SupabaseClient client;
  LugarRemoteDatasource(this.client);

  Future<Map<String, dynamic>?> getLugarDetalle(int lugarId) async {
    final res = await client.rpc('get_lugar_detalle', params: {
      'p_lugar_id': lugarId,
    });
    if (res == null || (res as List).isEmpty) return null;
    return res.first as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPublicacionesPorLugar({
    required int lugarId,
    required String userId,
    String? lastCreatedAt,
  }) async {
    return await client.rpc('get_publicaciones_por_lugar', params: {
      'p_lugar_id': lugarId,
      'p_user_uuid': userId,
      'p_limit': 20,
      'p_last_created_at': lastCreatedAt,
    });
  }

  Future<void> updateLugar(int id, Map<String, dynamic> data) async {
    await client.from('lugares').update(data).eq('id', id);
  }

  Future<List<FavoritePlaceModel>> getFavoritePlaces(String userId) async {
    final response = await client.from('favorite_places').select('''
          lugar_id,
          lugares!inner (
            id_lugar,
            nombre_lugar,
            foto_portada_url,
            id_categoria,
            id_departamento,
            es_verificado,
            categorias!inner (nombre_categoria),
            departamentos!inner (nombre_departamento)
          )
        ''').eq('user_id', userId);

    return response.map((fav) {
      final lugar = fav['lugares'] as Map<String, dynamic>;
      return FavoritePlaceModel.fromMap({
        'id_lugar': lugar['id_lugar'],
        'nombre_lugar': lugar['nombre_lugar'],
        'foto_portada_url': lugar['foto_portada_url'],
        'id_categoria': lugar['id_categoria'],
        'id_departamento': lugar['id_departamento'],
        'es_verificado': lugar['es_verificado'],
        'categoria_nombre': lugar['categorias']['nombre_categoria'],
        'departamento_nombre': lugar['departamentos']['nombre_departamento'],
      });
    }).toList();
  }

  Future<void> toggleFavorite(
      {required String userId, required int lugarId}) async {
    final existing = await client
        .from('favorite_places')
        .select()
        .eq('user_id', userId)
        .eq('lugar_id', lugarId);

    if (existing.isEmpty) {
      await client.from('favorite_places').insert({
        'user_id': userId,
        'lugar_id': lugarId,
      });
    } else {
      await client
          .from('favorite_places')
          .delete()
          .eq('user_id', userId)
          .eq('lugar_id', lugarId);
    }
  }
}
