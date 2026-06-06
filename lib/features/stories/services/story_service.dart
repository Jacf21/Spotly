import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/story_model.dart';

class StoryService {
  final supabase = Supabase.instance.client;

  // =========================
  // CAMARA
  // =========================
  Future<XFile?> takePhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 60,//  reduce peso antes de subir a Supabase
    );
    return picked;
  }

  // =========================
  // GALERIA
  // =========================
  Future<XFile?> pickGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,//  optimización para storage
    );
    return picked;
  }

  // =========================
  // SUBIR STORY
  // =========================
  Future<void> uploadStory(XFile imageFile) async {
    final user = supabase.auth.currentUser;
    //  seguridad: no permitir subir sin sesión
    if (user == null) return;
     //  nombre único para evitar colisiones en Storage
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final bytes = await imageFile.readAsBytes();
     //  subida directa a Supabase Storage
    await supabase.storage
        .from('Stories')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,// no sobrescribe archivos existentes
          ),
        );
     // obtener URL pública del archivo subido
    final imageUrl = supabase.storage
        .from('Stories')
        .getPublicUrl(fileName);
//  registrar story en base de datos
    await supabase.from('historias').insert({
      'id_usuario': user.id,
      'imagen_url': imageUrl,
    });
  }

  // =========================
  // GET STORIES (SIN FILTROS)
  // =========================
  Future<List<StoryModel>> getStories() async {
  final response = await supabase
  .from('historias')
  .select('''
    id,
    id_usuario,
    imagen_url,
    created_at,
    expires_at,
    perfiles (
      nombre_usuario,
      foto_perfil_url
    ),
    historias_vistas (
      id_usuario
    )
  ''')
  // ⚠️ solo stories no expiradas
  .gt('expires_at', DateTime.now().toIso8601String())
  .order('created_at', ascending: true);

  return (response as List)
      .map((e) => StoryModel.fromMap(e))
      .toList();
}

  // =========================
  // MARCAR VISTA
  // =========================
  Future<void> markAsViewed(String storyId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
   // upsert = evita duplicados (1 usuario = 1 vista por story)
    await supabase.from('historias_vistas').upsert({
      'id_historia': storyId,
      'id_usuario': user.id,
    });
  }

  // =========================
  // DELETE
  // =========================
  Future<void> deleteStory(String storyId) async {
    await supabase
        .from('historias')
        .delete()
        .eq('id', storyId);
  }

  Future<List<Map<String, dynamic>>> getStoryViews(String storyId) async {
  final response = await supabase
      .from('historias_vistas')
.select('''
  id,
  id_historia,
  id_usuario,
  perfiles (
    nombre_usuario,
    foto_perfil_url
  )
''')
.eq('id_historia', storyId);

  return List<Map<String, dynamic>>.from(response);
}

}