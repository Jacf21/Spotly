import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// páginas
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/user_home_page.dart';
import '../../features/auth/presentation/pages/guest_home_page.dart';
import '../../features/auth/presentation/pages/admin_dashboard_page.dart';
import '../../features/posts/presentation/pages/feed_page.dart';

// layout
import '../../core/widgets/main_navigation.dart';

final appRouter = GoRouter(
  initialLocation: '/login',  // ← Mantiene /login como inicial
  
  routes: [
    /// 🔓 RUTAS PÚBLICAS (sin menú de navegación)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    
    /// 👤 SHELL PARA USUARIOS AUTENTICADOS (con menú principal)
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: '/user',
          builder: (context, state) => const UserHomePage(),
        ),
        GoRoute(
          path: '/feed',
          builder: (context, state) => const FeedPage(),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text("Mapa"))),
        ),
        GoRoute(
          path: '/post',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text("Publicar"))),
        ),
        GoRoute(
          path: '/alerts',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text("Alertas"))),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text("Perfil"))),
        ),
      ],
    ),
    
    /// 👀 SHELL PARA INVITADOS (con navegación limitada)
    ShellRoute(
      builder: (context, state, child) {
        return GuestHomePage(child: child);
      },
      routes: [
        GoRoute(
          path: '/guest/home',
          builder: (context, state) =>
              const Center(child: Text('Home Invitado')),
        ),
        GoRoute(
          path: '/guest/map',
          builder: (context, state) =>
              const Center(child: Text('Mapa Invitado')),
        ),
        GoRoute(
          path: '/guest/messages',
          builder: (context, state) =>
              const Center(child: Text('Mensajes')),
        ),
        GoRoute(
          path: '/guest/profile',
          builder: (context, state) =>
              const Center(child: Text('Perfil Invitado')),
        ),
      ],
    ),
    
    /// 🛠 ADMIN
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),
  ],
);