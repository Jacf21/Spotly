import 'package:supabase_flutter/supabase_flutter.dart';

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

  // Búsqueda de personas sugeridas para seguir
  Future<List<Map<String, dynamic>>> getPeopleSuggestions() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return [];

      // Obtenemos primero la lista de IDs de las personas que el usuario ACTUAL ya sigue
      final List<dynamic> siguiendoResponse = await _supabase
          .from('seguidores')
          .select('id_usuario_seguido')
          .eq('id_usuario_seguidor', currentUserId);

      // Convertimos la respuesta en un Set de Strings para búsquedas rápidas
      final Set<String> idsSeguidos = siguiendoResponse
          .map((item) => item['id_usuario_seguido'].toString())
          .toSet();

      // Traemos los perfiles sugeridos
      final response = await _supabase
          .from('perfiles')
          .select('*')
          // Filtro primordial: No sugerirse a sí mismo
          .not('id_usuario', 'eq', currentUserId) 
          .limit(30);

      final List<dynamic> perfilesData = response as List<dynamic>;

      // Dejamos pasar solo los perfiles cuyo ID NO esté en el Set de seguidos
      final List<Map<String, dynamic>> sugerenciasFiltradas = perfilesData
          .map((profile) => Map<String, dynamic>.from(profile))
          .where((profile) => !idsSeguidos.contains(profile['id_usuario']))
          .take(7) // Limitamos a 7 sugerencias para no saturar el carrusel
          .toList();

      for (var perfil in sugerenciasFiltradas) {
        perfil['ya_lo_sigo'] = false;
      }

      return sugerenciasFiltradas;

    } catch (e) {
      print('Error al obtener sugerencias filtradas: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllPeopleDiscover() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      if (currentUserId == null) return [];

      // Traemos la lista de las personas que el usuario ACTUAL ya sigue
      final List<dynamic> siguiendoResponse = await _supabase
          .from('seguidores')
          .select('id_usuario_seguido')
          .eq('id_usuario_seguidor', currentUserId);

      final Set<String> idsSeguidos = siguiendoResponse
          .map((item) => item['id_usuario_seguido'].toString())
          .toSet();

      // Traemos todos los perfiles
      final response = await _supabase
          .from('perfiles')
          .select('*')
          .not('id_usuario', 'eq', currentUserId)
          .order('nombres', ascending: true); // Opcional: ordenarlos alfabéticamente

      final List<dynamic> perfilesData = response as List<dynamic>;

      return perfilesData.map((profile) {
        final Map<String, dynamic> profileMap = Map<String, dynamic>.from(profile);
        profileMap['ya_lo_sigo'] = idsSeguidos.contains(profileMap['id_usuario']);
        
        return profileMap;
      }).toList();

    } catch (e) {
      print('Error al obtener todos los perfiles en Discover: $e');
      return [];
    }
  }
}