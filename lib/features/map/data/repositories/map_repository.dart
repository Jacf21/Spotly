import '../datasources/map_remote_datasource.dart';
import '../models/map_lugar_model.dart';

class MapRepository {
  final MapRemoteDatasource datasource;
  MapRepository(this.datasource);

  Future<List<MapLugarModel>> getLugaresConCoordenadas() async {
    final data = await datasource.getLugaresConCoordenadas();
    return data.map((j) => MapLugarModel.fromJson(j)).toList();
  }

  Future<List<MapLugarModel>> buscarLugares(String query) async {
    final data = await datasource.buscarLugares(query);
    return data.map((j) => MapLugarModel.fromJson(j)).toList();
  }
}