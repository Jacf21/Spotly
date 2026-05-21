// features/admin/data/repositories/publicaciones_repository_impl.dart

import '../../domain/publicaciones_repository.dart';
import '../datasources/publicaciones_datasource.dart';

class PublicacionesRepositoryImpl implements PublicacionesRepository {
  final PublicacionesDatasource _ds;
  PublicacionesRepositoryImpl(this._ds);

  @override
  Future<({int totalPublicaciones, int totalReportes, int conReportes})>
      getStats() async {
    final results = await Future.wait([
      _ds.countPublicaciones(),
      _ds.countReportes(),
      _ds.countPublicacionesConReportes(),
    ]);
    return (
      totalPublicaciones: results[0],
      totalReportes: results[1],
      conReportes: results[2],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getReportadas() async {
    final raw = await _ds.fetchReportes();

    final grouped = <dynamic, Map<String, dynamic>>{};
    for (final r in raw) {
      final pub = r['publicaciones'];
      if (pub == null) continue;
      final id = pub['id_publicacion'];
      grouped.putIfAbsent(
        id,
        () => {'publicaciones': pub, 'reportes': <Map>[]},
      );
      (grouped[id]!['reportes'] as List).add(r);
    }
    return grouped.values.toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getTodas() => _ds.fetchPublicaciones();

  @override
  Future<void> toggleActivo({
    required int pubId,
    required String idUsuario,
    required bool esActivoActual,
    required String? adminId,
  }) async {
    final nuevoEstado = !esActivoActual;

    // Ejecutar secuencialmente — Future.wait con `if` condicional
    // dentro de la lista causa excepción en runtime (pantalla blanca)
    await _ds.updateActivo(pubId, nuevoEstado);

    await _ds.insertNotificacion(
      idUsuarioDestino: idUsuario,
      idUsuarioActor: adminId,
      pubId: pubId,
      nuevoEstado: nuevoEstado,
    );

    if (!nuevoEstado) {
      await _ds.markReportesResueltos(pubId);
    }
  }

   @override
  Future<void> ignorarReportes({
    required int pubId,
    required String idUsuario,
    required String? adminId,
  }) async {
    await _ds.ignorarReportes(pubId);
  }
}