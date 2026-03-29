import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'spotly_ui.dart';

class AdminDashboardContent extends StatelessWidget {
  final bool isDarkMode;
  final int selectedIndex;
  final VoidCallback onToggleTheme;
  final Function(int) onNavTap;
  final VoidCallback onSearch;
  final Function(String) onRedirect;
  final Widget child;

  const AdminDashboardContent({
    super.key,
    required this.isDarkMode,
    required this.selectedIndex,
    required this.onToggleTheme,
    required this.onNavTap,
    required this.onSearch,
    required this.onRedirect,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: SpotlyConfig.animShort,
      color: SpotlyColors.bg(isDarkMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Usamos el BottomNavigationBar nativo para mayor estabilidad visual
        bottomNavigationBar: _buildBottomNav(),
        body: Column(
          children: [
            // TOP BAR con isAdmin: true para mostrar el badge PRO/ADMIN
            SpotlyTopBar(
              dark: isDarkMode,
              isAdmin: true,
              onTheme: onToggleTheme,
              onSearch: onSearch,
            ),

            // CONTENIDO DINÁMICO CENTRAL
            Expanded(
              child: ClipRRect(
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 95,
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
            // 1. DASHBOARD (Métricas generales)
            SpotlyNavItem(
              icon: LucideIcons.layoutDashboard,
              label: 'Inicio',
              active: selectedIndex == 0,
              dark: isDarkMode,
              onTap: () => onNavTap(0),
            ),

            // 2. GESTIÓN (Mapa de Spots/Control)
            SpotlyNavItem(
              icon: LucideIcons.mapPin,
              label: 'Gestión',
              active: selectedIndex == 1,
              dark: isDarkMode,
              onTap: () => onNavTap(1),
            ),

            // 3. BOTÓN CENTRAL PLUS (Mismo estilo que User/Guest)
            SpotlyAddButton(
              dark: isDarkMode,
              onTap: () => onRedirect('Crear'),
            ),

            // 4. REPORTES (Alertas de usuarios o errores)
            SpotlyNavItem(
              icon: LucideIcons.barChart3,
              label: 'Reportes',
              active: selectedIndex == 2,
              dark: isDarkMode,
              onTap: () => onNavTap(2),
            ),

            // 5. PANEL (Configuración técnica del sistema)
            SpotlyNavItem(
              icon: LucideIcons.shieldCheck,
              label: 'Panel',
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
