import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'spotly_ui.dart';

class GuestHomeContent extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Function(int) onNavItemTapped;
  final Function(String) onGuestAction;
  final int selectedIndex;
  final Widget child;

  const GuestHomeContent({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onNavItemTapped,
    required this.onGuestAction,
    required this.selectedIndex,
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
              onSearch: () => onGuestAction('buscar destinos'),
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
              onTap: () => onNavItemTapped(0),
            ),
            SpotlyNavItem(
              icon: LucideIcons.map, // Estandarizado a Mapa
              label: 'Mapa',
              active: selectedIndex == 1,
              dark: isDarkMode,
              onTap: () {
                onNavItemTapped(1);
                onGuestAction('ver mapa');
              },
            ),
            SpotlyAddButton(
              dark: isDarkMode,
              onTap: () => onGuestAction('crear contenido'),
            ),
            SpotlyNavItem(
              icon: LucideIcons.messageSquare, // Estandarizado a Mensajes
              label: 'Mensajes',
              active: selectedIndex == 2,
              dark: isDarkMode,
              onTap: () {
                onNavItemTapped(2);
                onGuestAction('ver mensajes');
              },
            ),
            SpotlyNavItem(
              icon: LucideIcons.user,
              label: 'Perfil',
              active: selectedIndex == 3,
              dark: isDarkMode,
              onTap: () {
                onNavItemTapped(3);
                onGuestAction('ver perfil');
              },
            ),
          ],
        ),
      ),
    );
  }
}
