// features/admin/data/datasources/publicaciones_datasource.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class PublicacionesDatasource {
  final SupabaseClient _client;
  PublicacionesDatasource(this._client);

  Future<int> countPublicaciones() async {
    final res = await _client
        .from('publicaciones')
        .select('id_publicacion')
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> countReportes() async {
    final res = await _client
        .from('reportes_publicaciones')
        .select('id_reporte')
        .count(CountOption.exact);
    return res.count;
  }

  Future<int> countPublicacionesConReportes() async {
    final data = await _client
        .from('reportes_publicaciones')
        .select('id_publicacion')
        .eq('pendiente', true);
    return (data as List).map((r) => r['id_publicacion']).toSet().length;
  }

  Future<List<Map<String, dynamic>>> fetchReportes() async {
    // Query simple sin joins anidados
    final data = await _client
        .from('reportes_publicaciones')
        .select('id_reporte, motivo, pendiente, created_at, id_publicacion')
        .eq('pendiente', true)
        .order('created_at', ascending: false);

    final reportes = List<Map<String, dynamic>>.from(data);
    if (reportes.isEmpty) return [];

    final ids = reportes.map((r) => r['id_publicacion']).toSet().toList();

    // Trae publicaciones sin multimedia
    final pubs = await _client
        .from('publicaciones')
        .select('''
          id_publicacion,
          titulo,
          descripcion_experiencia,
          es_activo,
          id_usuario,
          perfiles!publicaciones_id_usuario_fkey (
            nombres,
            apellidos,
            nombre_usuario
          )
        ''')
        .inFilter('id_publicacion', ids);

    final pubsMap = {
      for (final p in List<Map<String, dynamic>>.from(pubs))
        p['id_publicacion']: p
    };

    // Trae imágenes de portada separado
    final multimedia = await _client
        .from('multimedia')
        .select('id_publicacion, url_recurso, es_portada')
        .inFilter('id_publicacion', ids)
        .eq('es_portada', true);

    final multimediaMap = {
      for (final m in List<Map<String, dynamic>>.from(multimedia))
        m['id_publicacion']: m['url_recurso'] as String?
    };

    // Combina todo
    for (final pub in pubsMap.values) {
      final id = pub['id_publicacion'];
      pub['media_url'] = multimediaMap[id];
    }

    return reportes.map((r) {
      final pub = pubsMap[r['id_publicacion']];
      if (pub == null) return null;
      return {...r, 'publicaciones': pub};
    }).whereType<Map<String, dynamic>>().toList();
  }

  Future<List<Map<String, dynamic>>> fetchPublicaciones() async {
    // Query simple sin multimedia anidada
    final data = await _client
        .from('publicaciones')
        .select('''
          id_publicacion,
          titulo,
          descripcion_experiencia,
          es_activo,
          like_count,
          comentario_count,
          created_at,
          id_usuario,
          perfiles!publicaciones_id_usuario_fkey (
            nombres,
            apellidos,
            nombre_usuario
          )
        ''')
        .order('created_at', ascending: false)
        .limit(60);

    final pubs = List<Map<String, dynamic>>.from(data);
    if (pubs.isEmpty) return [];

    final ids = pubs.map((p) => p['id_publicacion']).toList();

    // Trae imágenes de portada
    final multimedia = await _client
        .from('multimedia')
        .select('id_publicacion, url_recurso, es_portada')
        .inFilter('id_publicacion', ids)
        .eq('es_portada', true);

    final multimediaMap = {
      for (final m in List<Map<String, dynamic>>.from(multimedia))
        m['id_publicacion']: m['url_recurso'] as String?
    };

    // Añade media_url a cada publicación
    for (final pub in pubs) {
      pub['media_url'] = multimediaMap[pub['id_publicacion']];
    }

    return pubs;
  }

  Future<void> updateActivo(int pubId, bool nuevoEstado) async {
    await _client
        .from('publicaciones')
        .update({'es_activo': nuevoEstado})
        .eq('id_publicacion', pubId);
  }

  Future<void> markReportesResueltos(int pubId) async {
    await _client
        .from('reportes_publicaciones')
        .update({'pendiente': false})
        .eq('id_publicacion', pubId)
        .eq('pendiente', true);
  }

  Future<void> ignorarReportes(int pubId) async {
    await _client
        .from('reportes_publicaciones')
        .update({'pendiente': false})
        .eq('id_publicacion', pubId)
        .eq('pendiente', true);
  }

  Future<void> insertNotificacion({
    required String idUsuarioDestino,
    required String? idUsuarioActor,
    required int pubId,
    required bool nuevoEstado,
  }) async {
    final contenido = nuevoEstado
        ? '✅ Tu publicación ha sido restaurada por el equipo de Spotly.'
        : '⚠️ Tu publicación fue bloqueada por el equipo de Spotly por incumplir las normas de la comunidad.';

    await _client.from('notificaciones').insert({
      'id_usuario_destino': idUsuarioDestino,
      'id_usuario_actor': idUsuarioActor,
      'tipo': 'advertencia_publicacion',
      'id_publicacion': pubId,
      'contenido': contenido,
      'leido': false,
    });
  }
}