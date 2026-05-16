import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart'; 
import 'package:spotly/features/auth/presentation/pages/login_page.dart';
import 'package:spotly/features/auth/presentation/pages/register_page.dart';
import 'package:spotly/features/auth/presentation/pages/admin_dashboard_page.dart';
import 'package:spotly/features/auth/presentation/pages/auth_callback_page.dart';
import 'package:spotly/features/posts/presentation/pages/feed_page.dart';
import 'package:spotly/features/posts/presentation/pages/publication_page.dart';
import 'package:spotly/features/profile/presentation/pages/profile_page.dart';
import 'package:spotly/features/places/presentation/pages/lugar_profile_page.dart';
import 'package:spotly/features/posts/presentation/pages/user_profile_page.dart';
import 'package:spotly/features/notifications/alerts_page.dart';
import 'package:spotly/features/map/presentation/pages/map_page.dart';
import 'package:spotly/core/widgets/main_navigation.dart';

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
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigation(child: child);
      },
      routes: [
        GoRoute(
          path: '/feed',
          builder: (context, state) {
            return FeedPage(
              targetPostId: state.uri.queryParameters['postId'],
              targetCommentId: state.uri.queryParameters['commentId'],
            );
          },
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) {
            // El extra puede ser un LatLng (navegando desde un perfil de lugar)
            final lugarInicial = state.extra as LatLng?;
            return MapPage(lugarInicial: lugarInicial);
          },
        ),
        GoRoute(
          path: '/post',
          builder: (context, state) =>
              const CreatePostPage(),
        ),
        GoRoute(
          path: '/alerts',
          builder: (context, state) => const AlertsPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/user/:userId',
          name: 'user_profile',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return UserProfilePage(userId: userId);
          },
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
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),
  ],
);
