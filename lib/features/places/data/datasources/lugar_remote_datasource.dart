import 'package:supabase_flutter/supabase_flutter.dart';

class LugarRemoteDatasource {
  final SupabaseClient client;
  LugarRemoteDatasource(this.client);

  Future<Map<String, dynamic>?> getLugarDetalle(int lugarId) async {
    // NO agregues parámetros extras que la función RPC no espera
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

  // MÉTODO PARA ACTUALIZAR LUGAR
  Future<void> updateLugar(int id, Map<String, dynamic> data) async {
    try {
      final Map<String, dynamic> cleanData = {};

      final allowedFields = {
        'nombre_lugar',
        'descripcion',
        'resumen',
        'direccion',
        'altura_msnm',
        'clima_recomendado',
        'mejor_epoca_visitar',
        'informacion_util',
        'foto_portada_url',
      };

      data.forEach((key, value) {
        if (allowedFields.contains(key) && value != null) {
          cleanData[key] = value;
        }
      });

      if (cleanData.isEmpty) {
        print("No hay campos válidos para actualizar");
        return;
      }

      print("Actualizando lugar $id con: $cleanData");

      await client.from('lugares').update(cleanData).eq('id_lugar', id);
    } catch (e) {
      print("Error detallado en updateLugar: $e");
      throw Exception('Error al actualizar lugar: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCategorias() async {
    try {
      final response = await client
          .from('categorias')
          .select('id_categoria, nombre_categoria');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error obteniendo categorías: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDepartamentos() async {
    try {
      final response = await client
          .from('departamentos')
          .select('id_departamento, nombre_departamento');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error obteniendo departamentos: $e");
      return [];
    }
  }
}
