import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:spotly/features/auth/presentation/pages/login_page.dart';
import 'package:spotly/features/auth/presentation/pages/register_page.dart';
import 'package:spotly/features/auth/presentation/pages/auth_callback_page.dart';
import 'package:spotly/features/posts/presentation/pages/feed_page.dart';
import 'package:spotly/features/posts/presentation/pages/publication_page.dart';
import 'package:spotly/features/profile/presentation/pages/profile_page.dart';
import 'package:spotly/features/places/presentation/pages/lugar_profile_page.dart';
import 'package:spotly/features/posts/presentation/pages/user_profile_page.dart';
import 'package:spotly/features/notifications/alerts_page.dart';
import 'package:spotly/features/map/presentation/pages/map_page.dart';
import 'package:spotly/core/widgets/main_navigation.dart';
import 'package:spotly/features/places/presentation/pages/favorites_places_page.dart';
import 'package:spotly/features/profile/presentation/pages/followers_page.dart';

// ── Páginas admin ──────────────────────────────────────────────────────────
import 'package:spotly/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:spotly/features/admin/presentation/pages/admin_usuarios_page.dart';
import 'package:spotly/features/admin/presentation/pages/admin_publicaciones_page.dart';
import 'package:spotly/features/admin/presentation/pages/admin_lugares_page.dart';
import 'package:spotly/features/admin/presentation/pages/admin_profile_page.dart';

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
    // ── Rutas sin shell (no muestran navbar) ──────────────────────────────
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

    // ── Shell único: MainNavigation maneja tanto usuarios como admins ──────
    ShellRoute(
      builder: (context, state, child) => MainNavigation(child: child),
      routes: [

        // ── Rutas de usuario normal ────────────────────────────────────────
        GoRoute(
          path: '/feed',
          builder: (context, state) => FeedPage(
            targetPostId: state.uri.queryParameters['postId'],
            targetCommentId: state.uri.queryParameters['commentId'],
          ),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) {
            final lugarInicial = state.extra as LatLng?;
            return MapPage(lugarInicial: lugarInicial);
          },
        ),
        GoRoute(
          path: '/post',
          builder: (context, state) => const CreatePostPage(),
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
          path: '/favoritos',
          builder: (context, state) => const FavoritesPlacesPage(),
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
        GoRoute(
          path: '/followers/:userId/:type',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final type = state.pathParameters['type']!;
            return FollowersPage(userId: userId, showFollowers: type == 'followers');
          },
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfilePage(),
        ),

        // Rutas admin
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardPage(),
        ),
        GoRoute(
          path: '/admin/usuarios',
          builder: (context, state) => const AdminUsuariosPage(),
        ),
        GoRoute(
          path: '/admin/publicaciones',
          builder: (context, state) => const AdminPublicacionesPage(),
        ),
        GoRoute(
          path: '/admin/lugares',
          builder: (context, state) => const AdminLugaresPage(),
        ),
        GoRoute(
          path: '/admin/perfil',
          builder: (context, state) => const AdminProfilePage(),
        ),
      ],
    ),
  ],
);