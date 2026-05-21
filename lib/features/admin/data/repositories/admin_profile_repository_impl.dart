import 'package:supabase_flutter/supabase_flutter.dart';

class AdminProfileRepository {
  final SupabaseClient supabase;

  AdminProfileRepository(this.supabase);

  Future<Map<String, dynamic>> getProfile(String userId) async {
    final response = await supabase
        .from('perfiles')
        .select()
        .eq('id_usuario', userId)
        .single();

    return response;
  }

  Future<void> updateProfile({
    required String userId,
    required String nombres,
    required String apellidos,
    required String username,
  }) async {
    await supabase.from('perfiles').update({
      'nombres': nombres,
      'apellidos': apellidos,
      'nombre_usuario': username,
    }).eq('id_usuario', userId);
  }

  Future<void> changePassword(String newPassword) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}