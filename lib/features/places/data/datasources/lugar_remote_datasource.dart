import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/features/destinations/data/models/favorite_place_model.dart';

class LugarRemoteDatasource {
  final SupabaseClient client;
  LugarRemoteDatasource(this.client);

  /// Obtiene el detalle completo de un lugar usando una función SQL (RPC)
  /// Retorna un solo registro o null si no existe
  Future<Map<String, dynamic>?> getLugarDetalle(int lugarId) async {
    final res = await client.rpc('get_lugar_detalle', params: {
      'p_lugar_id': lugarId,
    });
    // Si no hay datos, retorna null
    if (res == null || (res as List).isEmpty) return null;
    return res.first as Map<String, dynamic>;
  }
  /// Obtiene publicaciones relacionadas a un lugar específico
  /// Soporta paginación con lastCreatedAt
  Future<List<dynamic>> getPublicacionesPorLugar({
    required int lugarId,
    required String userId,
    String? lastCreatedAt,
  }) async {
    return await client.rpc('get_publicaciones_por_lugar', params: {
      'p_lugar_id': lugarId,
      'p_user_uuid': userId,
       // límite de resultados por carga (paginación)
      'p_limit': 20,
      // último registro cargado para continuar la paginación
      'p_last_created_at': lastCreatedAt,
    });
  }
   /// Actualiza información de un lugar en la base de datos
  Future<void> updateLugar(int id, Map<String, dynamic> data) async {
    try {

      // Limpia el mapa eliminando valores null para evitar errores en Supabase
      final Map<String, dynamic> cleanData = {};
      data.forEach((key, value) {
        if (value != null) {
          cleanData[key] = value;
        }
      });


      // IMPORTANTE: Usar 'id_lugar' en lugar de 'id'
      await client
          .from('lugares')
          .update(cleanData)
          .eq('id_lugar', id) // ← CORREGIDO: id_lugar
          .select();

    } catch (e) {
      rethrow;
    }
  }
   /// Obtiene la lista de lugares favoritos de un usuario
  /// Une la tabla favoritos_lugares con lugares y sus relaciones
  Future<List<FavoritePlaceModel>> getFavoritePlaces(String userId) async {
    final response = await client.from('favoritos_lugares').select('''
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
     // Convertimos cada resultado en un modelo de Dart
    return response.map((fav) {
      final lugar = fav['lugares'] as Map<String, dynamic>;
      return FavoritePlaceModel.fromMap({
        'id_lugar': lugar['id_lugar'],
        'nombre_lugar': lugar['nombre_lugar'],
        'foto_portada_url': lugar['foto_portada_url'],
        'id_categoria': lugar['id_categoria'],
        'id_departamento': lugar['id_departamento'],
        'es_verificado': lugar['es_verificado'],
         // Datos de relaciones (categoría y departamento)
        'categoria_nombre': lugar['categorias']['nombre_categoria'],
        'departamento_nombre': lugar['departamentos']['nombre_departamento'],
      });
    }).toList();
  }
    /// Activa o desactiva un lugar favorito (toggle)
  /// Si no existe → lo crea, si existe → lo elimina
  Future<void> toggleFavorite(
      {required String userId, required int lugarId}) async {
        // Verifica si ya existe el favorito
    final existing = await client
        .from('favoritos_lugares')
        .select()
        .eq('user_id', userId)
        .eq('lugar_id', lugarId);

    if (existing.isEmpty) {
      // Si no existe → lo agrega a favoritos
      await client.from('favoritos_lugares').insert({
        'user_id': userId,
        'lugar_id': lugarId,
      });
    } else {
      await client
       // Si existe → lo elimina (toggle off)
          .from('favoritos_lugares')
          .delete()
          .eq('user_id', userId)
          .eq('lugar_id', lugarId);
    }
  }
}
