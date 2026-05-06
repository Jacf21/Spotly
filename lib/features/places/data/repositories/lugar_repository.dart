import '../datasources/lugar_remote_datasource.dart';
import '../models/lugar_detalle_model.dart';
import '../models/lugar_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class LugarRepository {
  final LugarRemoteDatasource datasource;
  final _client = Supabase.instance.client;
  LugarRepository(this.datasource);

  Future<LugarDetalleModel?> getDetalle(int lugarId) async {
    final data = await datasource.getLugarDetalle(lugarId);
    if (data == null) return null;
    return LugarDetalleModel.fromJson(data);
  }

  Future<List<LugarPostModel>> getPublicaciones({
    required int lugarId,
    required String userId,
    String? lastCreatedAt,
  }) async {
    final data = await datasource.getPublicacionesPorLugar(
      lugarId: lugarId,
      userId: userId,
      lastCreatedAt: lastCreatedAt,
    );
    return data.map((j) => LugarPostModel.fromJson(j)).toList();
  }
  Future<bool> isFavorite({
  required String userId,
  required int lugarId,
}) async {
  final res = await _client
      .from('favoritos_lugares')
      .select()
      .eq('user_id', userId)
      .eq('lugar_id', lugarId)
      .maybeSingle();

  return res != null;
}
Future<void> toggleFavorite({
  required String userId,
  required int lugarId,
}) async {
  try {
    // 🔍 verificar estado REAL en BD
    final existing = await _client
        .from('favoritos_lugares')
        .select()
        .eq('user_id', userId)
        .eq('lugar_id', lugarId)
        .maybeSingle();

    if (existing != null) {
      // 🗑 eliminar
      await _client
          .from('favoritos_lugares')
          .delete()
          .eq('user_id', userId)
          .eq('lugar_id', lugarId);

      print("🗑 eliminado de favoritos");
    } else {
      // 💾 insertar
      await _client.from('favoritos_lugares').insert({
        'user_id': userId,
        'lugar_id': lugarId,
      });

      print("💜 agregado a favoritos");
    }
  } catch (e) {
    print("❌ ERROR toggleFavorite: $e");
    rethrow;
  }
}
}