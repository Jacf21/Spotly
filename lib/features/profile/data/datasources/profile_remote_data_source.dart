import 'package:supabase_flutter/supabase_flutter.dart';
// Ruta corregida según tu estructura
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile(String userId);
  Future<void> updateProfile(UserModel user);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserModel> getProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('perfiles') // Asegúrate que este sea el nombre en Supabase
          .select()
          .eq('id_usuario', userId)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      // Si hay error, lanzamos una excepción clara para que el Bloc la capture
      throw Exception("Error al obtener datos de Supabase: $e");
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    try {
      await supabaseClient
          .from('perfiles')
          .update(user.toJson())
          .eq('id_usuario', user.id);
    } catch (e) {
      throw Exception("Error al actualizar en Supabase: $e");
    }
  }
}
