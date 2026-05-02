import '../datasources/lugar_remote_datasource.dart';
import '../models/lugar_detalle_model.dart';
import '../models/lugar_post_model.dart';

class LugarRepository {
  final LugarRemoteDatasource datasource;
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
}