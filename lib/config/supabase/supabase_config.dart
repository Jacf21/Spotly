import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    try {
      // 1. Intentamos obtener las variables
      final url = dotenv.env['SUPABASE_URL'];
      final key = dotenv.env['SUPABASE_ANON_KEY'];

      // 2. Verificación sin romper la app
      if (url == null || url.isEmpty || key == null || key.isEmpty) {
        debugPrint(
            '⚠️ Alerta: Variables de Supabase vacías o no encontradas en .env');
        return; // Salimos sin lanzar Exception para permitir que la UI cargue
      }

      // 3. Inicialización oficial
      await Supabase.initialize(
        url: url,
        anonKey: key,
        // Opcional: puedes añadir opciones de persistencia aquí
      );

      debugPrint('🚀 Supabase inicializado correctamente');
    } catch (e) {
      // Capturamos cualquier error (CORS en web, red, etc.)
      debugPrint('❌ Error crítico en SupabaseConfig: $e');
    }
  }

  /// Getter seguro para el cliente
  static SupabaseClient get client => Supabase.instance.client;
}
