import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/themes/spotly_config.dart';
import '../../../../core/widgets/layout/spotly_topbar.dart';
import '../../../../core/widgets/layout/spotly_nav_item.dart';
import '../../../../core/widgets/layout/spotly_add_button.dart';

class AdminDashboardContent extends StatelessWidget {
  final bool isDarkMode;
  final int selectedIndex;
  final VoidCallback onToggleTheme;
  final VoidCallback onSearch;
  final Widget child;

  const AdminDashboardContent({
    super.key,
    required this.isDarkMode,
    required this.selectedIndex,
    required this.onToggleTheme,
    required this.onSearch,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: SpotlyConfig.animShort,
      color: SpotlyColors.bg(isDarkMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: _buildBottomNav(context),
        body: Column(
          children: [
            SpotlyTopBar(
              dark: isDarkMode,
              isAdmin: true,
              onTheme: onToggleTheme,
              onSearch: onSearch,
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
            SpotlyNavItem(
              icon: LucideIcons.layoutDashboard,
              label: 'Inicio',
              active: selectedIndex == 0,
              dark: isDarkMode,
              onTap: () => context.go('/admin/dashboard'),
            ),

            SpotlyNavItem(
              icon: LucideIcons.mapPin,
              label: 'Gestión',
              active: selectedIndex == 1,
              dark: isDarkMode,
              onTap: () => context.go('/admin/gestion'),
            ),

            SpotlyAddButton(
              dark: isDarkMode,
              onTap: () => context.go('/admin/create'),
            ),

            SpotlyNavItem(
              icon: LucideIcons.barChart3,
              label: 'Reportes',
              active: selectedIndex == 2,
              dark: isDarkMode,
              onTap: () => context.go('/admin/reports'),
            ),

            SpotlyNavItem(
              icon: LucideIcons.shieldCheck,
              label: 'Panel',
              active: selectedIndex == 3,
              dark: isDarkMode,
              onTap: () => context.go('/admin/panel'),
            ),
          ],
        ),
      ),
    );
  }
}