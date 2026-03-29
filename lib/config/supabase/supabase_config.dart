import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Declaramos las variables a nivel de clase
  static String? _url;
  static String? _key;

  static Future<void> initialize() async {
    //Asignamos los valores del .env a las variables de la clase
    _url = dotenv.env['SUPABASE_URL'];
    _key = dotenv.env['SUPABASE_ANON_KEY'];

    if (_url == null || _key == null) {
      throw Exception('❌ Variables de entorno de Supabase no encontradas');
    }

    //Inicializamos Supabase aquí mismo para mayor comodidad
    await Supabase.initialize(
      url: _url!,
      anonKey: _key!,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  //Los getters ahora apuntan a las variables de la clase
  static String get url => _url ?? '';
  static String get anonKey => _key ?? '';
}