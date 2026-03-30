import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../themes/spotly_colors.dart';
import '../interactive/spotly_interactive.dart';
import '../common/spotly_logo.dart';

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
                _TopBarIconButton(
                  icon: LucideIcons.search,
                  dark: dark,
                  onTap: onSearch,
                ),
              ],
            ),
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