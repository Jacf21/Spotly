import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/user_home_page.dart';
import '../../features/auth/presentation/pages/guest_home_page.dart';
import '../../features/auth/presentation/pages/admin_dashboard_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    // 👤 USER
    GoRoute(
      path: '/user',
      builder: (context, state) => const UserHomePage(),
    ),

    // 👀 GUEST
    GoRoute(
      path: '/guest/home',
      builder: (context, state) => GuestHomePage(
        child: const Center(child: Text('Home Invitado')),
      ),
    ),

    GoRoute(
      path: '/guest/map',
      builder: (context, state) => GuestHomePage(
        child: const Center(child: Text('Mapa Invitado')),
      ),
    ),

    GoRoute(
      path: '/guest/messages', // 👈 FALTABA ESTA
      builder: (context, state) => GuestHomePage(
        child: const Center(child: Text('Mensajes')),
      ),
    ),

    GoRoute(
      path: '/guest/profile',
      builder: (context, state) => GuestHomePage(
        child: const Center(child: Text('Perfil Invitado')),
      ),
    ),

    // 🛠 ADMIN
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardPage(),
    ),
  ],
);