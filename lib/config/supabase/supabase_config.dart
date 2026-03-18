import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static final String supabaseUrl = 'SUPABASE_URL';
  static final String supabaseAnonKey = 'SUPABASE_ANON_KEY';

  static Future<void> initialize() async {
    final url = dotenv.get(supabaseUrl);
    final key = dotenv.get(supabaseAnonKey);

    await Supabase.initialize(
      url: url,
      anonKey: key,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}