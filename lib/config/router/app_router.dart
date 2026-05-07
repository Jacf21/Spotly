import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotly/features/posts/presentation/pages/publication_page.dart';

// páginas
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/admin_dashboard_page.dart';
import '../../features/posts/presentation/pages/feed_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/auth_callback_page.dart';
import '../../features/places/presentation/pages/lugar_profile_page.dart';
import '../../features/notifications/alerts_page.dart';

// layout
import '../../core/widgets/main_navigation.dart';

final appRouter = GoRouter(
  initialLocation: '/login',

  redirect: (context, state) {
    final location = state.uri.toString();

    if (location.contains('login-callback') || location.contains('code=')) {
      return '/auth/callback';
    }

    return null;
  },

  routes: [
    /// 🔓 RUTAS PÚBLICAS
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),

    GoRoute(
      path: '/login-callback',
      builder: (context, state) => const AuthCallbackPage(),
    ),

    GoRoute(
      path: '/auth/callback',
      builder: (context, state) => const AuthCallbackPage(),
    ),

    /// 🔐 APP CON NAVBAR
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigation(child: child);
      },
      routes: [
        /// FEED
        GoRoute(
          path: '/feed',
          builder: (context, state) {
            return FeedPage(
              targetPostId: state.uri.queryParameters['postId'],
              targetCommentId: state.uri.queryParameters['commentId'],
            );
          },
        ),

        /// MAPA
        GoRoute(
          path: '/map',
          builder: (context, state) =>
              const Center(child: Text("Mapa")),
        ),

        /// CREAR POST
        GoRoute(
          path: '/post',
          builder: (context, state) =>
              const CreatePostPage(),
        ),

        /// ALERTAS
        GoRoute(
          path: '/alerts',
          builder: (context, state) =>
              const AlertsPage(),
        ),

        /// PERFIL
        GoRoute(
          path: '/profile',
          builder: (context, state) =>
              const ProfilePage(),
        ),
        GoRoute(
          path: '/lugar/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return LugarProfilePage(lugarId: id);
          },
        ),
      ],
    ),

    /// 🛠 ADMIN
    GoRoute(
      path: '/admin',
      builder: (context, state) =>
          const AdminDashboardPage(),
    ),
  ],
);
