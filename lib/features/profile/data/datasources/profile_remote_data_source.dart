import 'package:supabase_flutter/supabase_flutter.dart';
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

      return ProfileModel.fromJson(response);
    } catch (e) {
      throw Exception("Error al obtener datos de Supabase: $e");
    }
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    try {
      // 1. Convertimos el modelo a un mapa JSON
      final Map<String, dynamic> updateData = profile.toJson();

      // 2. FILTRADO INTELIGENTE:
      // Eliminamos campos que sean null o strings vacíos ("").
      // Esto evita que Postgres intente validar formatos de fecha vacíos.
      updateData.removeWhere((key, value) {
        return value == null || (value is String && value.trim().isEmpty);
      });

      // 3. Seguridad: Nos aseguramos de no enviar el ID en el cuerpo del UPDATE
      // (aunque Supabase lo ignora, es buena práctica)
      updateData.remove('id_usuario');

      // 4. Ejecutamos la actualización solo si hay datos para cambiar
      if (updateData.isNotEmpty) {
        await supabaseClient
            .from('perfiles')
            .update(updateData)
            .eq('id_usuario', profile.idUsuario);
      }
    } catch (e) {
      // Ahora este catch atrapará errores de forma más limpia
      throw Exception("Error al actualizar en Supabase: $e");
    }
  }
}
