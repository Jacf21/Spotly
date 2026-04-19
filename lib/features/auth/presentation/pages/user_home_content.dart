import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/themes/spotly_config.dart';
import '../../../../core/widgets/layout/spotly_topbar.dart';
import '../../../../core/widgets/layout/spotly_nav_item.dart';
import '../../../../core/widgets/layout/spotly_add_button.dart';

class UserHomeContent extends StatelessWidget {
  final bool isDarkMode;
  final int selectedIndex;
  final VoidCallback onToggleTheme;
  final Function(int) onNavTap;
  final VoidCallback onSearch;
  final Function(String) onAction;
  final Widget child;

  const UserHomeContent({
    super.key,
    required this.isDarkMode,
    required this.selectedIndex,
    required this.onToggleTheme,
    required this.onNavTap,
    required this.onSearch,
    required this.onAction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
              onSearch: onSearch,
            ),
            Expanded(
              child: ClipRRect(
                child: child,
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
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
              active: selectedIndex == 0,
              dark: isDarkMode,
              onTap: () => onNavTap(0),
            ),
            SpotlyNavItem(
              icon: LucideIcons.map,
              label: 'Mapa',
              active: selectedIndex == 1,
              dark: isDarkMode,
              onTap: () => onNavTap(1),
            ),
            SpotlyAddButton(
              dark: isDarkMode,
              onTap: () => onAction('Subir foto o reseña'),
            ),
            SpotlyNavItem(
              icon: LucideIcons.messageSquare, // Cambiado a Mensajes
              label: 'Mensajes',
              active: selectedIndex == 2,
              dark: isDarkMode,
              onTap: () => onNavTap(2),
            ),
            SpotlyNavItem(
              icon: LucideIcons.user,
              label: 'Perfil',
              active: selectedIndex == 3,
              dark: isDarkMode,
              onTap: () => onNavTap(3),
            ),
          ],
        ),
      ),
    );
  }
}
