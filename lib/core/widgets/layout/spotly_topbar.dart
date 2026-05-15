import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../themes/spotly_colors.dart';
import '../interactive/spotly_interactive.dart';
import '../common/spotly_logo.dart';
import '../../context/auth_context.dart';
import '../auth/logout_service.dart';

class SpotlyTopBar extends StatelessWidget {
  final bool dark;
  final VoidCallback onTheme;
  final VoidCallback onSearch;
  final bool isAdmin;

  const SpotlyTopBar({
    super.key,
    required this.dark,
    required this.onTheme,
    required this.onSearch,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: SpotlyColors.nav(dark),
        border: Border(
          bottom: BorderSide(
            color: dark
                ? Colors.white10
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SpotlyLogo(dark: dark, size: 28),

            if (isAdmin) _AdminBadge(),

            Row(
              children: [
                _TopBarIconButton(
                  icon: dark ? LucideIcons.sun : LucideIcons.moon,
                  dark: dark,
                  onTap: onTheme,
                ),

                const SizedBox(width: 12),

                if (isLoggedIn)
                  _TopBarIconButton(
                    icon: LucideIcons.search,
                    dark: dark,
                    onTap: onSearch,
                  ),

                if (isLoggedIn) ...[
                  const SizedBox(width: 12),

                  PopupMenuButton<String>(
                    color: SpotlyColors.card(dark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    icon: Icon(
                      LucideIcons.moreVertical,
                      color: SpotlyColors.text(dark),
                      size: 22,
                    ),

                    onSelected: (value) async {
                      if (value == 'logout') {
                        await LogoutService.logout(
                          context: context,
                          dark: dark,
                        );
                      }
                    },

                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.logOut,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// 🔥 Badge ADMIN con animación
class _AdminBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'ADMIN PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
  }
}

/// 🔘 Botón de icono del topbar
class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;

  const _TopBarIconButton({
    required this.icon,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SpotlyInteractive(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.04),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: SpotlyColors.text(dark),
          size: 22,
        ),
      ),
    );
  }
}