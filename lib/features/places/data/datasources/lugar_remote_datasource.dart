import 'package:supabase_flutter/supabase_flutter.dart';

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
}