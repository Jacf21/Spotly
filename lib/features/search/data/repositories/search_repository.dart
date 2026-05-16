import 'package:supabase_flutter/supabase_flutter.dart';

// Este repositorio se encarga de manejar las consultas a Supabase para obtener los lugares 
// cercanos o por departamento, dependiendo del filtro seleccionado
class SearchRepository {
  final _supabase = Supabase.instance.client;

  // Búsqueda por Distancia usando la columna 'ubicacion'
  Future<List<Map<String, dynamic>>> getNearbyPlaces(double lat, double lng, double km) async {
    final List<dynamic> data = await _supabase.rpc(
      'buscar_lugares_por_distancia',
      params: {
        'user_lat': lat,
        'user_lng': lng,
        'distancia_metros': km * 1000,
      },
    );
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getDepartamentos() async {
    final data = await _supabase
        .from('departamentos')
        .select('id_departamento, nombre_departamento')
        .order('nombre_departamento');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getPlacesByDept(int deptId) async {
    try {
      final data = await _supabase
          .from('lugares')
          .select()
          .eq('id_departamento', deptId);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error en Repo Depto: $e");
      return [];
    }
  }
}