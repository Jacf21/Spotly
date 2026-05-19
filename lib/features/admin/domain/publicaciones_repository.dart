abstract class PublicacionesRepository {
  /// Totales: publicaciones, reportes, publicaciones con reportes
  Future<({int totalPublicaciones, int totalReportes, int conReportes})> getStats();

  /// Publicaciones que tienen al menos un reporte, agrupadas
  Future<List<Map<String, dynamic>>> getReportadas();

  /// Todas las publicaciones (últimas 60)
  Future<List<Map<String, dynamic>>> getTodas();

  /// Cambia es_activo y envía notificación al autor
  Future<void> toggleActivo({
    required int pubId,
    required String idUsuario,
    required bool esActivoActual,
    required String? adminId,
  });

  Future<void> ignorarReportes({
    required int pubId,
    required String idUsuario,
    required String? adminId,
  });
}