import 'package:supabase_flutter/supabase_flutter.dart';

class UsuariosDatasource {
  final SupabaseClient _client;
  UsuariosDatasource(this._client);

  Future<List<Map<String, dynamic>>> fetchUsuarios() async {
    final data = await _client
        .from('perfiles')
        .select('''
          id_usuario,
          nombres,
          apellidos,
          nombre_usuario,
          email,
          foto_perfil_url,
          biografia,
          rol,
          es_activo,
          es_verificado,
          total_publicaciones,
          total_seguidores,
          total_seguidos,
          fecha_registro,
          ultima_conexion,
          ban_hasta,
          motivo_ban
        ''')
        .order('fecha_registro', ascending: false);

    final usuarios = List<Map<String, dynamic>>.from(data);
    if (usuarios.isEmpty) return [];

    final ids = usuarios.map((u) => u['id_usuario'].toString()).toList();

    // Conteo real de publicaciones (excluyendo compartidas)
    final pubs = await _client
        .from('publicaciones')
        .select('id_usuario')
        .inFilter('id_usuario', ids)
        .eq('es_compartido', false);

    final pubMap = <String, int>{};
    for (final p in List<Map<String, dynamic>>.from(pubs)) {
      final id = p['id_usuario'].toString();
      pubMap[id] = (pubMap[id] ?? 0) + 1;
    }

    // Conteo real de seguidores
    final segs = await _client
        .from('seguidores')
        .select('id_usuario_seguido')
        .inFilter('id_usuario_seguido', ids);

    final segMap = <String, int>{};
    for (final s in List<Map<String, dynamic>>.from(segs)) {
      final id = s['id_usuario_seguido'].toString();
      segMap[id] = (segMap[id] ?? 0) + 1;
    }

    // Conteo de reportes pendientes por usuario
    final reportes = await _client
        .from('reportes_cuenta')
        .select('id_usuario_reportado')
        .eq('pendiente', true);

    final reporteMap = <String, int>{};
    for (final r in List<Map<String, dynamic>>.from(reportes)) {
      final id = r['id_usuario_reportado'].toString();
      reporteMap[id] = (reporteMap[id] ?? 0) + 1;
    }

    for (final u in usuarios) {
      final id = u['id_usuario'].toString();
      u['pub_count_real'] = pubMap[id] ?? 0;
      u['seguidores_count_real'] = segMap[id] ?? 0;
      u['reportes_pendientes'] = reporteMap[id] ?? 0;
    }

    return usuarios;
  }

  Future<void> banearUsuario({
    required String userId,
    required String tipoBan, // 'temporal' | 'definitivo'
    required String? motivoBan,
  }) async {
    final banHasta = tipoBan == 'temporal'
        ? DateTime.now().add(const Duration(days: 90)).toIso8601String()
        : null; // null = definitivo

    await _client.from('perfiles').update({
      'es_activo': false,
      'ban_hasta': banHasta,
      'motivo_ban': motivoBan,
    }).eq('id_usuario', userId);
  }

  Future<void> desbanearUsuario(String userId) async {
    await _client.from('perfiles').update({
      'es_activo': true,
      'ban_hasta': null,
      'motivo_ban': null,
    }).eq('id_usuario', userId);
  }

  Future<void> cambiarRol({
    required String userId,
    required String nuevoRol,
  }) async {
    await _client
        .from('perfiles')
        .update({'rol': nuevoRol})
        .eq('id_usuario', userId);
  }
}