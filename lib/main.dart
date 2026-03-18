import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotly/config/supabase/supabase_config.dart';
import 'package:spotly/config/router/app_router.dart';
import 'package:spotly/config/themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno
  await dotenv.load(fileName: '.env');
  
  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  runApp(const TurismoBoliviaApp());
}

class TurismoBoliviaApp extends StatelessWidget {
  const TurismoBoliviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Turismo Bolivia',
      //theme: AppTheme.lightTheme,
      //routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}