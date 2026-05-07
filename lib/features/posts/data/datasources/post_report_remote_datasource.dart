import 'package:supabase_flutter/supabase_flutter.dart';

class PostReportRemoteDatasource {
  final SupabaseClient client;

  PostReportRemoteDatasource(this.client);

  Future<void> reportPost({
    required int postId, // id_publicacion
    required String userId,
    String? motivo,
  }) async {
    await client.from('reportes_publicaciones').insert({
      'id_publicacion': postId,
      'user_id': userId,
      'motivo': motivo ?? 'Sin motivo',
    });
  }
}