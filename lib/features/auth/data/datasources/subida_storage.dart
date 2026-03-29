import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PostRemoteDataSource {
  Future<void> uploadPost({
    required File imageFile,
    required String title,
    required String description,
    required int deptoId,
    required double lat,
    required double lng,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final SupabaseClient supabase;

  PostRemoteDataSourceImpl(this.supabase);

  @override
  Future<void> uploadPost({
  required File imageFile,
  required String title,
  required String description,
  required int deptoId,
  required double lat,
  required double lng,
  }) async {
  try {
    //Intentar obtener el usuario, pero no bloquear si es null
    final user = supabase.auth.currentUser;
    final String? userId = user?.id; // Si no hay usuario, será null

    //Subir Imagen al Storage
    final extension = imageFile.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    
    await supabase.storage
        .from('imagen_publicacion')
        .upload(fileName, imageFile);

    final imageUrl = supabase.storage
        .from('imagen_publicacion')
        .getPublicUrl(fileName);

    //Ejecutar RPC
    await supabase.rpc('publicar_contenido_completo', params: {
      'p_titulo': title,
      'p_descripcion_experiencia': description,
      'p_nombre_lugar': 'Prueba en Punata', 
      'p_departamento_id': deptoId,
      'p_city': 'Punata',
      'p_coords': 'POINT($lng $lat)',
      'p_id_usuario': userId, // Aquí pasamos el null o el ID real
      'p_url_foto': imageUrl,
    });

    print("¡Publicación creada exitosamente!");

  } catch (e) {
    print("Error detectado: $e");
    throw Exception('Error en el DataSource: $e');
  }
}
}