import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/themes/spotly_config.dart';
import '../../../../core/widgets/layout/spotly_topbar.dart';
import '../../../../core/widgets/layout/spotly_nav_item.dart';
import '../../../../core/widgets/layout/spotly_add_button.dart';

class GuestHomeContent extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Function(String) onGuestAction;
  final Widget child;

  const GuestHomeContent({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onGuestAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    return AnimatedContainer(
      duration: SpotlyConfig.animShort,
      color: SpotlyColors.bg(isDarkMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SpotlyTopBar(
              dark: isDarkMode,
              isAdmin: false,
              onTheme: onToggleTheme,
              onSearch: () => onGuestAction('buscar destinos'),
            ),
            Expanded(child: child),
            _buildBottomNav(context, location),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, String location) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: SpotlyColors.nav(isDarkMode),
        border: Border(
          top: BorderSide(
            color: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SpotlyNavItem(
              icon: LucideIcons.home,
              label: 'Inicio',
              active: _isActive(location, '/guest/home'),
              dark: isDarkMode,
              onTap: () => context.go('/guest/home'),
            ),

            SpotlyNavItem(
              icon: LucideIcons.map,
              label: 'Mapa',
              active: _isActive(location, '/guest/map'),
              dark: isDarkMode,
              onTap: () {
                context.go('/guest/map');
                onGuestAction('ver mapa');
              },
            ),

            SpotlyAddButton(
              dark: isDarkMode,
              onTap: () => onGuestAction('crear contenido'),
            ),

            SpotlyNavItem(
              icon: LucideIcons.messageSquare,
              label: 'Mensajes',
              active: _isActive(location, '/guest/messages'),
              dark: isDarkMode,
              onTap: () {
                context.go('/guest/messages');
                onGuestAction('ver mensajes');
              },
            ),

            SpotlyNavItem(
              icon: LucideIcons.user,
              label: 'Perfil',
              active: _isActive(location, '/guest/profile'),
              dark: isDarkMode,
              onTap: () {
                context.go('/guest/profile');
                onGuestAction('ver perfil');
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Detecta tab activo según la ruta
  bool _isActive(String location, String route) {
    return location.startsWith(route);
  }
}