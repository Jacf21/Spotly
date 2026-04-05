import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:spotly/config/supabase/supabase_config.dart';

// 📦 IMPORTACIONES
import '/features/auth/presentation/pages/admin_dashboard_page.dart';
import '/features/auth/presentation/pages/user_home_page.dart';
import '/features/auth/presentation/pages/guest_home_page.dart';
import '/features/auth/presentation/pages/login_page.dart';
import '/features/auth/presentation/pages/register_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initAppServices();

  runApp(const TurismoBoliviaApp());
}

Future<void> _initAppServices() async {
  try {
    await dotenv.load(fileName: ".env");
    await SupabaseConfig.initialize();

    debugPrint("🌐 Spotly: Servicios y Auth listos");
  } catch (e) {
    debugPrint("⚠️ Error crítico en el arranque: $e");
  }
}

/// 🌐 ROUTER GLOBAL
final GoRouter _router = GoRouter(
  initialLocation: '/dev',

  routes: [
    ///  DEV ACCESS
    GoRoute(
      path: '/dev',
      builder: (context, state) => const DeveloperAccessPage(),
    ),

    ///  LOGIN
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),

    ///  REGISTER
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    ///  USER
    GoRoute(
      path: '/user',
      builder: (context, state) => const UserHomePage(),
    ),

    ///  ADMIN
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),

    /// GUEST
    GoRoute(
      path: '/guest',
      builder: (context, state) => GuestHomePage(
         child: const Center(
       child: Text("Modo Invitado"),
        ),
     ),
    ),
  ],
);

class TurismoBoliviaApp extends StatelessWidget {
  const TurismoBoliviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Spotly Bolivia',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DD4BF),
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}

/// --- PÁGINA DE ACCESO PARA DESARROLLO ---
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
              const Color(0xFF2DD4BF).withOpacity(0.1),
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

                _AccessButton(
                  title: "ACCESO ADMIN",
                  subtitle: "Panel de Gestión Pro",
                  color: const Color(0xFFFF5722),
                  icon: Icons.admin_panel_settings_rounded,
                  onTap: () => context.go('/admin'),
                ),

                const SizedBox(height: 20),

                _AccessButton(
                  title: "ACCESO USUARIO",
                  subtitle: "Experiencia con Perfil",
                  color: const Color(0xFF2DD4BF),
                  icon: Icons.person_rounded,
                  onTap: () => context.go('/user'),
                ),

                const SizedBox(height: 20),

                _AccessButton(
                  title: "MODO INVITADO",
                  subtitle: "Exploración Limitada",
                  color: Colors.blueGrey,
                  icon: Icons.explore_rounded,
                  onTap: () => context.go('/guest'),
                ),

                const SizedBox(height: 20),

                _AccessButton(
                  title: "SIMULAR LOGIN",
                  subtitle: "Auth + Redirección por Rol",
                  color: const Color(0xFFA855F7),
                  icon: Icons.lock_open_rounded,
                  onTap: () => context.go('/'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// BOTÓN REUTILIZABLE
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
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
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