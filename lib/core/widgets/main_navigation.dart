import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:spotly/features/search/presentation/spotly_search_delegation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../context/auth_context.dart';
import '../utils/theme_utils.dart';
import '../themes/spotly_colors.dart';
import '../utils/spotly_ui.dart';
import '../widgets/layout/spotly_add_button.dart';
import '../widgets/layout/spotly_topbar.dart';
import '../utils/notifications_helper.dart';

class MainNavigation extends StatelessWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  int _getUserIndex(String location) {
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/post')) return 2;
    if (location.startsWith('/alerts')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  int _getAdminIndex(String location) {
    if (location.startsWith('/admin/usuarios')) return 1;
    if (location.startsWith('/admin/publicaciones')) return 2;
    if (location.startsWith('/admin/lugares')) return 3;
    if (location.startsWith('/admin/perfil')) return 4;
    return 0; // /admin o /admin/dashboard
  }

  Future<int> _getNotifFuture() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return Future.value(0);
    return getNotificationCount(userId);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdmin = auth.role == 'admin';
    final isGuest = !auth.isLoggedIn;
    final dark = ThemeUtils.isDark(context);
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = isAdmin ? _getAdminIndex(location) : _getUserIndex(location);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SpotlyTopBar(
          dark: dark,
          isAdmin: isAdmin,
          onTheme: () => ThemeUtils.toggle(context),
          onSearch: () => showSearch(
            context: context,
            delegate: SpotlySearchDelegate(dark: dark),
          ),
        ),
      ),

      body: child,

      bottomNavigationBar: _buildBottomNav(
        context,
        currentIndex,
        dark,
        isGuest,
        isAdmin,
        auth,
      ),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    int currentIndex,
    bool dark,
    bool isGuest,
    bool isAdmin,
    AuthProvider auth,
  ) {
    return SafeArea(
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          color: SpotlyColors.nav(dark),
          border: Border(
            top: BorderSide(
              color: dark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
        ),
        child: FutureBuilder<int>(
          key: ValueKey(GoRouterState.of(context).uri.toString()),
          future: _getNotifFuture(),
          builder: (context, snapshot) {
            final notifCount = snapshot.data ?? 0;

            // ── Admin: fila simple, sin botón flotante ──────────────────────
            if (isAdmin) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: SpotlyUI.buildNavItems(
                  currentIndex: currentIndex,
                  isDark: dark,
                  isAdmin: true,
                  notifCount: 0,
                  onTap: (index) {
                    switch (index) {
                      case 0: context.go('/admin'); break;
                      case 1: context.go('/admin/usuarios'); break;
                      case 2: context.go('/admin/publicaciones'); break;
                      case 3: context.go('/admin/lugares'); break;
                      case 4: context.go('/admin/perfil'); break;
                    }
                  },
                ),
              );
            }

            // ── Usuario normal: fila + botón central flotante ───────────────
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: SpotlyUI.buildNavItems(
                    currentIndex: currentIndex,
                    isDark: dark,
                    isAdmin: false,
                    notifCount: notifCount,
                    onTap: (index) {
                      if (isGuest && index > 1) {
                        context.go('/login');
                        return;
                      }
                      switch (index) {
                        case 0: context.go('/feed'); break;
                        case 1: context.go('/map'); break;
                        case 2: context.go('/post'); break;
                        case 3: context.go('/alerts'); break;
                        case 4: context.go('/profile'); break;
                      }
                    },
                  ),
                ),

                // Botón "+" centrado flotante
                Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SpotlyAddButton(
                      dark: dark,
                      onTap: () {
                        if (isGuest) { context.go('/login'); return; }
                        context.go('/post');
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}