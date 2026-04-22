import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class PostRemoteDataSource {
  Future<void> uploadPost({
    required XFile imageFile,
    required String title,
    required String description,
    required int deptoId,
    required String city,
    required double lat,
    required double lng,
    required String privacidad,
    required bool permiteComen,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final SupabaseClient supabase;

  PostRemoteDataSourceImpl(this.supabase);

  @override
  Future<void> uploadPost({
  required XFile imageFile,
  required String title,
  required String description,
  required int deptoId,
  required String city,
  required double lat,
  required double lng,
  required String privacidad,
  required bool permiteComen,

  }) async {

    //Validar sesión
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Debes iniciar sesión para publicar");
    final String userId = user.id;

    try {
    
      //Obtener los bytes (para Web y Móvil y no haya problemas con la imagen)
      final Uint8List imageBytes = await imageFile.readAsBytes();
      String extension = 'jpg';

      //Obtener la extensión de forma segura para Web y Móvil
      if (kIsWeb) {
        final String name = imageFile.name; 
        extension = name.split('.').last.toLowerCase();
      } else {
        extension = imageFile.path.split('.').last.toLowerCase();
      }

      // Limpieza básica por si la extensión falla
      if (extension.length > 4) extension = 'jpg';

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';

      //Subida por Binario
      await supabase.storage
          .from('imagen_publicacion')
          .uploadBinary(
            fileName, 
            imageBytes,
            fileOptions: FileOptions(
              contentType: 'image/$extension',
              upsert: false,
            ),
          );

      final imageUrl = supabase.storage
          .from('imagen_publicacion')
          .getPublicUrl(fileName);

      await supabase.rpc('publicar_contenido_completo', params: {
        'p_titulo': title,
        'p_descripcion_experiencia': description,
        'p_nombre_lugar': title, 
        'p_departamento_id': deptoId,
        'p_city': city,
        'p_coords': 'POINT($lng $lat)',
        'p_id_usuario': userId,
        'p_url_foto': imageUrl, 
        'p_privacidad': privacidad,
        'p_permite_comentarios': permiteComen,
      });

      print("¡Publicación creada exitosamente!");

    } catch (e) {
      print("Error detectado: $e");
      throw Exception('Error en el DataSource: $e');
    }
  }
}