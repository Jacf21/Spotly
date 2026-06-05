import 'package:supabase_flutter/supabase_flutter.dart';

class MapRemoteDatasource {
  final SupabaseClient client;
  MapRemoteDatasource(this.client);

  /// Obtener lugares con sus coordenadas
  Future<List<Map<String, dynamic>>> getLugaresConCoordenadas() async {
    final response = await client.rpc('get_lugares_con_coordenadas');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Busca lugares por nombre
  Future<List<Map<String, dynamic>>> buscarLugares(String query) async {
    final response = await client.rpc(
      'buscar_lugares',
      params: {'query': query},
    );
    return List<Map<String, dynamic>>.from(response);
  }
}