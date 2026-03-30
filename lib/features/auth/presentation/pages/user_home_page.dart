import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // IMPORTACIÓN VITAL
import 'user_home_content.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/themes/spotly_config.dart';
import '../../../../core/widgets/layout/spotly_topbar.dart';
import '../../../../core/widgets/layout/spotly_nav_item.dart';
import '../../../../core/widgets/layout/spotly_add_button.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  bool _isDarkMode = true;
  int _selectedIndex = 0;

  void _onNavTap(int index) => setState(() => _selectedIndex = index);
  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  @override
  Widget build(BuildContext context) {
    // LISTA DE VISTAS PARA EL USUARIO LOGUEADO
    final List<Widget> _userViews = [
      // 0. Feed Principal
      const _UserPlaceholder(
        icon: LucideIcons.sparkles,
        label: "Tu Feed Personalizado de Bolivia",
      ),

      // 1. Mapa Interactivo
      const _UserPlaceholder(
        icon: LucideIcons
            .mapPin, // Corregido de mapPinned a mapPin por compatibilidad
        label: "Explora lugares cercanos en el Mapa",
      ),

      // 2. Favoritos
      const _UserPlaceholder(
        icon: LucideIcons.heart, // Corregido de bookmarkHeart a heart
        label: "Tus Spots Guardados",
      ),

      // 3. Perfil de Usuario
      const _UserPlaceholder(
        icon: LucideIcons.user, // Corregido de userCircle a user
        label: "Configuración de tu Perfil",
      ),
    ];

    return UserHomeContent(
      isDarkMode: _isDarkMode,
      selectedIndex: _selectedIndex,
      onToggleTheme: _toggleTheme,
      onNavTap: _onNavTap,
      onSearch: () => debugPrint("Buscando lugares cerca de mí..."),
      onAction: (type) => debugPrint("Acción de usuario: $type"),

      // Mantenemos el estado de las páginas con IndexedStack para no recargar el mapa
      child: IndexedStack(
        index: _selectedIndex,
        children: _userViews,
      ),
    );
  }
}

// Widget auxiliar para diseño temporal optimizado con tu Arsenal
class _UserPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;
  const _UserPlaceholder({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    // Detectamos el brillo para adaptar el placeholder
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: SpotlyColors.accent(isDark).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 52, color: SpotlyColors.accent(isDark)),
          ),
          const SizedBox(height: 24),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: SpotlyColors.text(isDark).withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
