import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotly/config/supabase/supabase_config.dart'; 
import 'package:spotly/features/auth/presentation/pages/create_post_publication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    //Cargamos el archivo de texto .env a la memoria
    await dotenv.load(fileName: ".env");

    //Llamamos al método que configura e inicializa Supabase
    await SupabaseConfig.initialize();
    
    print("✅ Conexión establecida con el servidor de Spotly");
  } catch (e) {
    print("❌ Error crítico al iniciar la App: $e");
  }

  runApp(const SpotlyApp());
}

class SpotlyApp extends StatelessWidget {
  const SpotlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotly Bolivia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CreatePostPage(),
    );
  }
}