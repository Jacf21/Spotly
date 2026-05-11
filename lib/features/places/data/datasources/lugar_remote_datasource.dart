import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/features/destinations/data/models/favorite_place_model.dart';


class LugarRemoteDatasource {
  final SupabaseClient client;
  LugarRemoteDatasource(this.client);

  Future<Map<String, dynamic>?> getLugarDetalle(int lugarId) async {
    final res = await client.rpc('get_lugar_detalle',
        params: {'p_lugar_id': lugarId});
    if (res == null || (res as List).isEmpty) return null;
    return res.first as Map<String, dynamic>;
  }

  Future<List<dynamic>> getPublicacionesPorLugar({
    required int lugarId,
    required String userId,
    String? lastCreatedAt,
  }) async {
    return await client.rpc('get_publicaciones_por_lugar', params: {
      'p_lugar_id':       lugarId,
      'p_user_uuid':      userId,
      'p_limit':          20,
      'p_last_created_at': lastCreatedAt,
    });
  }

Future<List<FavoritePlaceModel>> getFavoritePlaces(String userId) async {
  try {
    final response = await client
        .from('favoritos_lugares')
        .select('''
          lugar_id,
          lugares (
            id_lugar,
            nombre_lugar,
            foto_portada_url,
            id_categoria,
            id_departamento,
            es_verificado
          )
        ''')
        .eq('user_id', userId);

    final List data = response as List;

    return data
        .where((item) =>
            item['lugares'] != null &&
            item['lugares']['id_lugar'] != null)
        .map((item) {
      final lugar = item['lugares'];

      return FavoritePlaceModel.fromMap({
        "id_lugar": lugar['id_lugar'],
        "nombre_lugar": lugar['nombre_lugar'] ?? '',
        "foto_portada_url": lugar['foto_portada_url'] ?? '',
        "id_categoria": lugar['id_categoria'],
        "id_departamento": lugar['id_departamento'],
        "es_verificado": lugar['es_verificado'] ?? false,
      });
    }).toList();
  } catch (e) {
    print("❌ ERROR FAVORITES: $e");
    return [];
  }
}

}