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
          like_count,
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

    // Cuenta publicaciones por lugar en query separada
    final ids = lugares.map((l) => l['id_lugar']).toList();
    final pubCounts = await _client
        .from('publicaciones')
        .select('id_lugar')
        .inFilter('id_lugar', ids);

    final countMap = <dynamic, int>{};
    for (final p in List<Map<String, dynamic>>.from(pubCounts)) {
      final id = p['id_lugar'];
      countMap[id] = (countMap[id] ?? 0) + 1;
    }

    for (final l in lugares) {
      l['publicaciones_count'] = countMap[l['id_lugar']] ?? 0;
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

  /// Trae las imágenes del bucket multimedia relacionadas al lugar
  /// usando la tabla multimedia (url_recurso, es_portada)
  Future<List<Map<String, dynamic>>> fetchImagenesLugar(int lugarId) async {
    // Busca en publicaciones del lugar las imágenes subidas
    final pubs = await _client
        .from('publicaciones')
        .select('id_publicacion')
        .eq('id_lugar', lugarId);

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