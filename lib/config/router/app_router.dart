import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// páginas
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/admin_dashboard_page.dart';
import '../../features/posts/presentation/pages/feed_page.dart';
import '../../features/notifications/alerts_page.dart';
// layout
import '../../core/widgets/main_navigation.dart';

final appRouter = GoRouter(
  initialLocation: '/login',

  routes: [
    /// 🔓 PÚBLICAS (SIN NAVBAR)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    /// 🔐 APP (CON NAVBAR GLOBAL)
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: '/feed',
          builder: (context, state) => const FeedPage(),
        ),

        GoRoute(
          path: '/post-detail/:id',
           builder: (context, state) {
            final id = state.pathParameters['id']!;
             return Scaffold(
                body: Center(
                child: Text("Post ID: $id"),
              ),
             );
           },
         ),
         
        GoRoute(
          path: '/map',
          builder: (context, state) =>
              const Center(child: Text("Mapa")),
        ),

        GoRoute(
          path: '/post',
          builder: (context, state) =>
              const Center(child: Text("Publicar")),
        ),

        GoRoute(
  path: '/alerts',
  builder: (context, state) => const AlertsPage(),
),
         
        GoRoute(
          path: '/profile',
          builder: (context, state) =>
              const Center(child: Text("Perfil")),
        ),
      ],
    ),

    /// 🛠 ADMIN (SIN NAVBAR SI QUIERES)
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),
  ],
);