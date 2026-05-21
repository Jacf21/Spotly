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
    required int notifCount,
  }) {
    if (isAdmin) {
      // ── Admin: 5 items distribuidos uniformemente, sin botón central ───────
      final items = [
        (LucideIcons.layoutDashboard, 'Panel',     0),
        (LucideIcons.users,           'Usuarios',      1),
        (LucideIcons.image,           'Publicaciones',         2),
        (LucideIcons.mapPin,          'Lugares',       3),
        (LucideIcons.user,            'Perfil',        4),
      ];

      return [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              final (icon, label, index) = item;
              return SpotlyNavItem(
                icon: icon,
                label: label,
                active: currentIndex == index,
                dark: isDark,
                onTap: () => onTap(index),
              );
            }).toList(),
          ),
        ),
      ];
    }

    // ── Usuario normal: izquierda / espacio para botón + / derecha ──────────
    return [
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
              icon: LucideIcons.map,
              label: 'Mapa',
              active: currentIndex == 1,
              dark: isDark,
              onTap: () => onTap(1),
            ),
          ],
        ),
      ),

      // Espacio central reservado para el SpotlyAddButton flotante
      const SizedBox(width: 80),

      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SpotlyNavItem(
              icon: LucideIcons.bell,
              label: 'Alertas',
              active: currentIndex == 3,
              dark: isDark,
              onTap: () => onTap(3),
              badgeCount: notifCount,
            ),
            SpotlyNavItem(
              icon: LucideIcons.user,
              label: 'Perfil',
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