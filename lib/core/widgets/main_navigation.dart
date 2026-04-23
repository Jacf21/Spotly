import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

  int _getIndex(String location) {
    if (location.startsWith('/feed')) return 0;
    if (location.startsWith('/map')) return 1;
    if (location.startsWith('/post')) return 2;
    if (location.startsWith('/alerts')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  Future<int> _getNotifFuture() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return Future.value(0);
    return getNotificationCount(userId);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _getIndex(location);

    final auth = context.watch<AuthProvider>();
    final isGuest = !auth.isLoggedIn;
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),

      /// 🔝 HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SpotlyTopBar(
          dark: dark,
          isAdmin: auth.role == 'admin',
          onTheme: () => ThemeUtils.toggle(context),
          onSearch: () {},
        ),
      ),

      /// 📦 CONTENIDO
      body: child,

      /// 🔻 NAVBAR
      bottomNavigationBar: _buildBottomNav(
        context,
        currentIndex,
        dark,
        isGuest,
        auth,
      ),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    int currentIndex,
    bool dark,
    bool isGuest,
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

            return Stack(
              clipBehavior: Clip.none,
              children: [
                /// 🔹 NAV ITEMS (YA ARMADOS)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: SpotlyUI.buildNavItems(
                    currentIndex: currentIndex,
                    isDark: dark,
                    isAdmin: auth.role == 'admin',
                    notifCount: notifCount,
                    onTap: (index) {
                      if (isGuest && index > 1) {
                        context.go('/login');
                        return;
                      }

                      switch (index) {
                        case 0:
                          context.go('/feed');
                          break;
                        case 1:
                          context.go('/map');
                          break;
                        case 2:
                          context.go('/post');
                          break;
                        case 3:
                          context.go('/alerts');
                          break;
                        case 4:
                          context.go('/profile');
                          break;
                      }
                    },
                  ),
                ),

                /// ➕ BOTÓN CENTRADO REAL
                Positioned(
                  top: -25,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SpotlyAddButton(
                      dark: dark,
                      onTap: () {
                        if (isGuest) {
                          context.go('/login');
                          return;
                        }
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