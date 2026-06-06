import '../datasources/lugar_remote_datasource.dart';
import '../models/lugar_detalle_model.dart';
import '../models/lugar_post_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/features/destinations/data/models/favorite_place_model.dart';

class LugarRepository {
  final LugarRemoteDatasource datasource;
   // Cliente directo de Supabase (usado solo para consultas simples aquí)
  final _client = Supabase.instance.client;
  LugarRepository(this.datasource);

  /// Obtiene el detalle completo de un lugar
  /// Convierte el JSON del datasource en un modelo tipado
  Future<LugarDetalleModel?> getDetalle(int lugarId) async {
    final data = await datasource.getLugarDetalle(lugarId);
    if (data == null) return null;
    return LugarDetalleModel.fromJson(data);
  }
 /// Obtiene la lista de lugares favoritos del usuario
  Future<List<FavoritePlaceModel>> getFavoritePlaces(
    String userId,
  ) async {
    return await datasource.getFavoritePlaces(userId);
  }
/// Obtiene publicaciones de un lugar con soporte de paginación
  /// lastCreatedAt se usa para cargar más datos (scroll infinito)
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
    // Convierte cada JSON en un modelo tipado
    return data.map((j) => LugarPostModel.fromJson(j)).toList();
  }
/// Verifica si un lugar está en favoritos del usuario
  /// Retorna true si existe registro en la tabla
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
/// Agrega o elimina un lugar de favoritos (toggle)
  /// Si existe → elimina
  /// Si no existe → inserta
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

  // MÉTODO PARA ACTUALIZAR LUGAR (alias para updateLugar)
  Future<void> actualizarLugar(int id, Map<String, dynamic> data) async {
    return await datasource.updateLugar(id, data);
  }
}
