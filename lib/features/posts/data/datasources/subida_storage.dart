import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/lugar_cercano_model.dart';

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

  Future<List<LugarCercanoModel>> buscarLugaresCercanos({
    required double lat,
    required double lng,
    int radioMetros = 100,
  }) async {
    final res = await supabase.rpc('buscar_lugares_cercanos', params: {
      'p_coords': 'POINT($lng $lat)',
      'p_radio_metros': radioMetros,
    });
    return (res as List)
        .map((j) => LugarCercanoModel.fromJson(j))
        .toList();
  }

  @override
  Future<void> uploadPost({
    required XFile imageFile,
    required String title,
    required String description,
    required int deptoId,
    required String city,
    required double lat,
    required double lng,
    required String privacidad,   // tu columa visible_para
    required bool permiteComen,   // tu columna comentario_activado
    String placeDescription = '',
    int? categoriaId,
    int? lugarIdExistente,

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
        'p_descripcion_lugar': placeDescription,
        'p_categoria_id': categoriaId,
        'p_lugar_id_existente': lugarIdExistente,
      });

      print("¡Publicación creada exitosamente!");

    } catch (e) {
      print("Error detectado: $e");
      throw Exception('Error en el DataSource: $e');
    }
  }
}