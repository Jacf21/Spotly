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
      imageQuality: 60,
    );
    return picked;
  }

  // =========================
  // GALERIA
  // =========================
  Future<XFile?> pickGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    return picked;
  }

  // =========================
  // SUBIR STORY
  // =========================
  Future<void> uploadStory(XFile imageFile) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final bytes = await imageFile.readAsBytes();

    await supabase.storage
        .from('Stories')
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false,
          ),
        );

    final imageUrl = supabase.storage
        .from('Stories')
        .getPublicUrl(fileName);

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