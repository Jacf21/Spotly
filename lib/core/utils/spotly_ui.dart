import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/layout/spotly_nav_item.dart';

class SpotlyUI {
  /// 🔔 TOAST
  static void toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// 🔻 NAVBAR ITEMS
  static List<Widget> buildNavItems({
    required int currentIndex,
    required bool isDark,
    required bool isAdmin,
    required Function(int) onTap,
  }) {
    return [
      /// IZQUIERDA
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SpotlyNavItem(
              icon: LucideIcons.home,
              label: 'Inicio',
              active: currentIndex == 0,
              dark: isDark,
              onTap: () => onTap(0),
            ),
            SpotlyNavItem(
              icon: LucideIcons.mapPin,
              label: 'Mapa',
              active: currentIndex == 1,
              dark: isDark,
              onTap: () => onTap(1),
            ),
          ],
        ),
      ),

      /// ESPACIO CENTRAL REAL
      const SizedBox(width: 80),

      /// DERECHA
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SpotlyNavItem(
              icon: isAdmin ? LucideIcons.layoutGrid : LucideIcons.heart,
              label: isAdmin ? 'Gestión' : 'Favoritos',
              active: currentIndex == 3,
              dark: isDark,
              onTap: () => onTap(3),
            ),
            SpotlyNavItem(
              icon: isAdmin ? LucideIcons.shieldCheck : LucideIcons.user,
              label: isAdmin ? 'Panel' : 'Perfil',
              active: currentIndex == 4,
              dark: isDark,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    ];
  }
}