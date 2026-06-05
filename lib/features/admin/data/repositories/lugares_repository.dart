// features/admin/data/repositories/lugares_repository.dart

import '../datasources/lugares_datasource.dart';
import '../models/admin_lugar_model.dart';

class LugaresRepository {
  final LugaresDatasource _ds;
  LugaresRepository(this._ds);

  /// Obtener informacion de un lugar turistico
  Future<List<AdminLugarModel>> getLugares() async {
    final data = await _ds.fetchLugares();
    return data.map(AdminLugarModel.fromJson).toList();
  }

  /// Obtener categorias
  Future<List<Map<String, dynamic>>> getCategorias() =>
      _ds.fetchCategorias();

  /// Obtener todas la imagenes asociada a un lugar turistico
  Future<List<Map<String, dynamic>>> getImagenesLugar(int lugarId) =>
      _ds.fetchImagenesLugar(lugarId);

  /// Editar informacion de un lugar turistico
  Future<void> updateLugar({
    required int lugarId,
    required String nombre,
    required String? descripcion,
    required int? idCategoria,
  }) =>
      _ds.updateLugar(
        lugarId: lugarId,
        nombre: nombre,
        descripcion: descripcion,
        idCategoria: idCategoria,
      );

  /// Editar foto de portada
  Future<void> updateFotoPortada({
    required int lugarId,
    required String nuevaUrl,
  }) =>
      _ds.updateFotoPortada(lugarId: lugarId, nuevaUrl: nuevaUrl);
}