import 'package:supabase_flutter/supabase_flutter.dart';

class LugaresDatasource {
  final SupabaseClient _client;
  LugaresDatasource(this._client);

  /// Lista todos los lugares con categoría, departamento, stats y foto portada
  Future<List<Map<String, dynamic>>> fetchLugares() async {
    final data = await _client
        .from('lugares')
        .select('''
          id_lugar,
          nombre_lugar,
          descripcion,
          resumen,
          foto_portada_url,
          es_verificado,
          es_destacado,
          created_at,
          categorias!lugares_id_categoria_fkey (
            id_categoria,
            nombre_categoria
          ),
          departamentos!lugares_id_departamento_fkey (
            id_departamento,
            nombre_departamento
          )
        ''')
        .order('created_at', ascending: false);

    final lugares = List<Map<String, dynamic>>.from(data);
    if (lugares.isEmpty) return [];

    final ids = lugares.map((l) => l['id_lugar']).toList();

    // Conteo de publicaciones por lugar
    final pubCounts = await _client
        .from('publicaciones')
        .select('id_lugar')
        .inFilter('id_lugar', ids);

    final pubCountMap = <dynamic, int>{};
    for (final p in List<Map<String, dynamic>>.from(pubCounts)) {
      final id = p['id_lugar'];
      pubCountMap[id] = (pubCountMap[id] ?? 0) + 1;
    }

    // Conteo de likes desde favoritos_lugares — query directa sin inFilter
    final likes = await _client
        .from('favoritos_lugares')
        .select('lugar_id');

    final likeCountMap = <dynamic, int>{};
    for (final l in List<Map<String, dynamic>>.from(likes)) {
      final id = l['lugar_id'];
      likeCountMap[id] = (likeCountMap[id] ?? 0) + 1;
    }

    for (final l in lugares) {
      final id = l['id_lugar'];
      l['publicaciones_count'] = pubCountMap[id] ?? 0;
      l['like_count'] = likeCountMap[id] ?? 0;
    }

    return lugares;
  }

  /// Trae todas las categorías para el selector del formulario
  Future<List<Map<String, dynamic>>> fetchCategorias() async {
    final data = await _client
        .from('categorias')
        .select('id_categoria, nombre_categoria')
        .order('nombre_categoria');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> fetchImagenesLugar(int lugarId) async {
    // Busca en publicaciones del lugar las imágenes subidas
    final pubs = await _client
        .from('publicaciones')
        .select('id_publicacion')
        .eq('id_lugar', lugarId)
        .eq('es_compartido', false);

    final pubIds = (pubs as List).map((p) => p['id_publicacion']).toList();
    if (pubIds.isEmpty) return [];

    final multimedia = await _client
        .from('multimedia')
        .select('id_multimedia, url_recurso, es_portada, id_publicacion')
        .inFilter('id_publicacion', pubIds)
        .eq('tipo_recurso', 'foto')
        .order('es_portada', ascending: false);

    return List<Map<String, dynamic>>.from(multimedia);
  }

  /// Actualiza nombre, descripción y categoría de un lugar
  Future<void> updateLugar({
    required int lugarId,
    required String nombre,
    required String? descripcion,
    required int? idCategoria,
  }) async {
    await _client.from('lugares').update({
      'nombre_lugar': nombre,
      'descripcion': descripcion,
      'id_categoria': idCategoria,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id_lugar', lugarId);
  }

  /// Cambia la foto de portada del lugar
  Future<void> updateFotoPortada({
    required int lugarId,
    required String nuevaUrl,
  }) async {
    await _client
        .from('lugares')
        .update({'foto_portada_url': nuevaUrl})
        .eq('id_lugar', lugarId);
  }
}