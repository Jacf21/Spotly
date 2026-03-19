import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotly/config/supabase/supabase_config.dart';
import 'package:spotly/core/test/test_connection_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar .env
  await dotenv.load(fileName: '.env');

  // Inicializar Supabase
  await SupabaseConfig.initialize();

  runApp(const TurismoBoliviaApp());
}

class TurismoBoliviaApp extends StatelessWidget {
  const TurismoBoliviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Turismo Bolivia',
      debugShowCheckedModeBanner: false,
      home: const TestConnectionPage(), // 👈 TEMPORAL para probar
    );
  }
}