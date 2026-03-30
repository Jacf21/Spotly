import 'package:go_router/go_router.dart';
import 'login_page.dart';
import 'user_home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/user',
      builder: (context, state) => const UserHomePage(),
    ),
  ],
);