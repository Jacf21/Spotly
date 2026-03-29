import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:spotly/config/supabase/supabase_config.dart';

// 📦 IMPORTACIONES CON RUTA ABSOLUTA (ESTILO ARQUITECTURA LIMPIA)
import '/features/auth/presentation/pages/admin_dashboard_page.dart';
import '/features/auth/presentation/pages/user_home_page.dart';
import '/features/auth/presentation/pages/guest_home_page.dart';
import '/features/auth/presentation/pages/login_page.dart';

Future<void> main() async {
  // 1. Asegurar que los bindings de Flutter estén listos antes de cualquier async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializar servicios (DotEnv + Supabase Real)
  await _initAppServices();

  runApp(const TurismoBoliviaApp());
}

Future<void> _initAppServices() async {
  try {
    // Carga las variables de entorno (.env)
    await dotenv.load(fileName: ".env");

    // Conexión real a tu proyecto de Supabase
    await SupabaseConfig.initialize();

    debugPrint("🌐 Spotly: Servicios y Auth listos");
  } catch (e) {
    debugPrint("⚠️ Error crítico en el arranque: $e");
    // Aquí podrías añadir una lógica de reintento si fuera necesario
  }
}

class TurismoBoliviaApp extends StatelessWidget {
  const TurismoBoliviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotly Bolivia',
      debugShowCheckedModeBanner: false,

      // Tema Global (Dark Mode Disruptivo)
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        fontFamily: 'Inter',
        // Personalización de acentos para que coincidan con tu marca
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DD4BF),
          brightness: Brightness.dark,
        ),
      ),

      // 3. DEFINICIÓN DE RUTAS
      // 'home' es la primera pantalla que se verá (DeveloperAccess)
      home: const DeveloperAccessPage(),

      // El Mapa de rutas permite que Navigator.pushReplacementNamed funcione
      routes: {
        '/login': (context) => const LoginPage(),
        '/user': (context) => const UserHomePage(),
        '/admin': (context) => const AdminDashboardPage(),
        '/guest': (context) => const GuestHomePage(),
      },
    );
  }
}

// --- PÁGINA DE ACCESO PARA DESARROLLO ---
class DeveloperAccessPage extends StatelessWidget {
  const DeveloperAccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              const Color(0xFF2DD4BF).withOpacity(0.1), // Cyan Spotly
              const Color(0xFF0F1117),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SPOTLY',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2DD4BF),
                    letterSpacing: -3,
                  ),
                ),
                const Text(
                  'DEVELOPER ACCESS',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 4,
                    color: Colors.white38,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 60),

                // ACCESO ADMIN
                _AccessButton(
                  title: "ACCESO ADMIN",
                  subtitle: "Panel de Gestión Pro",
                  color: const Color(0xFFFF5722),
                  icon: Icons.admin_panel_settings_rounded,
                  onTap: () => Navigator.pushNamed(context, '/admin'),
                ),
                const SizedBox(height: 20),

                // ACCESO USUARIO
                _AccessButton(
                  title: "ACCESO USUARIO",
                  subtitle: "Experiencia con Perfil",
                  color: const Color(0xFF2DD4BF),
                  icon: Icons.person_rounded,
                  onTap: () => Navigator.pushNamed(context, '/user'),
                ),
                const SizedBox(height: 20),

                // MODO INVITADO
                _AccessButton(
                  title: "MODO INVITADO",
                  subtitle: "Exploración Limitada",
                  color: Colors.blueGrey[400]!,
                  icon: Icons.explore_rounded,
                  onTap: () => Navigator.pushNamed(context, '/guest'),
                ),
                const SizedBox(height: 20),

                // SIMULACIÓN LOGIN REAL (Púrpura)
                _AccessButton(
                  title: "SIMULAR LOGIN",
                  subtitle: "Auth + Redirección por Rol",
                  color: const Color(0xFFA855F7),
                  icon: Icons.lock_open_rounded,
                  onTap: () => Navigator.pushNamed(context, '/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget auxiliar para los botones de acceso (Extraído para limpieza)
class _AccessButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _AccessButton({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 20),
            Expanded(
              // Usamos Expanded para evitar desbordamiento de texto
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}
