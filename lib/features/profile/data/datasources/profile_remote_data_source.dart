import 'package:supabase_flutter/supabase_flutter.dart';
// Importamos el modelo de perfil que creamos antes
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<void> updateProfile(ProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final response = await supabaseClient
          .from('perfiles')
          .select()
          .eq('id_usuario', userId)
          .single();

      // Convertimos la respuesta directamente a ProfileModel
      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception("Error al obtener datos de Supabase: $e");
    }
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      await supabaseClient.from('perfiles').update(profile.toJson()).eq(
          'id_usuario', profile.idUsuario); // Usamos idUsuario del ProfileModel
    } catch (e) {
      throw Exception("Error al actualizar en Supabase: $e");
    }
  }
}
