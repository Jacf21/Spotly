import 'package:supabase_flutter/supabase_flutter.dart';

class MapRemoteDatasource {
  final SupabaseClient client;
  MapRemoteDatasource(this.client);

  /// Trae todos los lugares con coordenadas extraídas del campo GEOGRAPHY.
  /// Requiere la función RPC `get_lugares_con_coordenadas` en Supabase.
  Future<List<Map<String, dynamic>>> getLugaresConCoordenadas() async {
    final response = await client.rpc('get_lugares_con_coordenadas');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Busca lugares por nombre usando la función RPC `buscar_lugares`.
  Future<List<Map<String, dynamic>>> buscarLugares(String query) async {
    final response = await client.rpc(
      'buscar_lugares',
      params: {'query': query},
    );
    return List<Map<String, dynamic>>.from(response);
  }
}