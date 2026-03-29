import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// =====================================================
/// 💎 SPOTLY UI SYSTEM · STACK REAL 2026 (FULL CONSOLIDATED)
/// =====================================================

class SpotlyColors {
  static Color bg(bool dark) =>
      dark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC);
  static Color card(bool dark) =>
      dark ? const Color(0xFF1E293B).withOpacity(0.7) : Colors.white;
  static Color nav(bool dark) => dark ? const Color(0xFF0F172A) : Colors.white;
  static Color accent(bool dark) =>
      dark ? const Color(0xFF2DD4BF) : const Color(0xFF0891B2);
  static Color text(bool dark) =>
      dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
  static Color subText(bool dark) =>
      dark ? Colors.blueGrey[400]! : Colors.blueGrey[600]!;

  static List<BoxShadow> shadow(bool dark) => [
        BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.5 : 0.08),
          blurRadius: 30,
          offset: const Offset(0, 15),
        )
      ];
}

class SpotlyConfig {
  static const Duration animShort = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Curve curve = Cubic(0.175, 0.885, 0.32, 1.275);
}

/// ===============================
/// 🧪 INTERACTIVE CORE (Haptic & Scale)
/// ===============================
class SpotlyInteractive extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scaleOnTap;

  const SpotlyInteractive(
      {super.key,
      required this.child,
      required this.onTap,
      this.scaleOnTap = 0.92});

  @override
  State<SpotlyInteractive> createState() => _SpotlyInteractiveState();
}

class _SpotlyInteractiveState extends State<SpotlyInteractive> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleOnTap : 1.0,
        duration: SpotlyConfig.animShort,
        curve: SpotlyConfig.curve,
        child: widget.child,
      ),
    );
  }
}

/// ===============================
/// 💠 SPOTLY BASIC COMPONENTS
/// ===============================

class SpotlyLogo extends StatelessWidget {
  final bool dark;
  final double size;
  const SpotlyLogo({super.key, required this.dark, this.size = 26});
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: size, fontWeight: FontWeight.w900, letterSpacing: -1.5),
        children: [
          TextSpan(
              text: 'SPOT', style: TextStyle(color: SpotlyColors.accent(dark))),
          TextSpan(
              text: 'LY', style: TextStyle(color: SpotlyColors.text(dark))),
        ],
      ),
    );
  }
}

class SpotlyCrystalCard extends StatelessWidget {
  final Widget child;
  final bool dark;
  const SpotlyCrystalCard({super.key, required this.child, required this.dark});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SpotlyColors.card(dark),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
            color: dark ? Colors.white.withOpacity(0.08) : Colors.black12),
        boxShadow: SpotlyColors.shadow(dark),
      ),
      child: child,
    );
  }
}

/// ===============================
/// ⏳ LOADING & STATUS
/// ===============================
class SpotlyLoader extends StatelessWidget {
  final bool dark;
  final String? message;
  const SpotlyLoader({super.key, required this.dark, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: SpotlyColors.accent(dark),
              strokeWidth: 3,
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds),
          ),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(message!,
                style: TextStyle(
                    color: SpotlyColors.subText(dark),
                    fontSize: 13,
                    letterSpacing: 1.1)),
          ]
        ],
      ),
    );
  }
}

/// ===============================
/// 🔝 TOP BAR (ADMIN AWARE)
/// ===============================
class SpotlyTopBar extends StatelessWidget {
  final bool dark;
  final VoidCallback onTheme;
  final VoidCallback onSearch;
  final bool isAdmin;

  const SpotlyTopBar(
      {super.key,
      required this.dark,
      required this.onTheme,
      required this.onSearch,
      this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: SpotlyColors.nav(dark),
        border: Border(
            bottom: BorderSide(
                color: dark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SpotlyLogo(dark: dark, size: 28),
            if (isAdmin) _buildAdminBadge(),
            Row(children: [
              _TopBarIconButton(
                  icon: dark ? LucideIcons.sun : LucideIcons.moon,
                  dark: dark,
                  onTap: onTheme),
              const SizedBox(width: 12),
              _TopBarIconButton(
                  icon: LucideIcons.search, dark: dark, onTap: onSearch),
            ])
          ],
        ),
      ),
    );
  }

  Widget _buildAdminBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFFF5722)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('ADMIN PRO',
          style: TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds);
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;
  const _TopBarIconButton(
      {required this.icon, required this.dark, required this.onTap});
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
        child: Icon(icon, color: SpotlyColors.text(dark), size: 22),
      ),
    );
  }
}

/// ===============================
/// 🔻 FOOTER & NAVIGATION
/// ===============================

class SpotlyNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool dark;
  final VoidCallback onTap;

  const SpotlyNavItem(
      {super.key,
      required this.icon,
      required this.label,
      required this.active,
      required this.dark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color =
        active ? SpotlyColors.accent(dark) : SpotlyColors.subText(dark);
    return Expanded(
      child: SpotlyInteractive(
        onTap: onTap,
        scaleOnTap: 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal)),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: SpotlyConfig.animShort,
              width: active ? 16 : 0,
              height: 2,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
            ),
          ],
        ),
      ),
    );
  }
}

class SpotlyAddButton extends StatelessWidget {
  final bool dark;
  final VoidCallback onTap;
  const SpotlyAddButton({super.key, required this.dark, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      alignment: Alignment.center,
      child: SpotlyInteractive(
        onTap: onTap,
        scaleOnTap: 0.85,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              SpotlyColors.accent(dark),
              SpotlyColors.accent(dark).withOpacity(0.7)
            ]),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: SpotlyColors.accent(dark).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8))
            ],
          ),
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 28),
        ),
      )
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(end: -4, duration: 2.seconds),
    );
  }
}

class SpotlyUI {
  /// Genera los items del footer dinámicamente según ROL (Admin/Guest)
  static List<Widget> buildNavItems({
    required int currentIndex,
    required bool isDark,
    required bool isAdmin,
    required Function(int) onTap,
  }) {
    return [
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
      const SizedBox(width: 65), // Espacio para AddButton
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
    ];
  }

  static void toast(BuildContext context, String message, bool dark) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor:
            dark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(50, 0, 50, 110),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
    );
  }
}

/// ===============================
/// 🖼️ FEED COMPONENTS (Images)
/// ===============================
class SpotlyImageCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool dark;

  const SpotlyImageCard(
      {super.key,
      required this.imageUrl,
      required this.title,
      required this.dark});

  @override
  Widget build(BuildContext context) {
    return SpotlyInteractive(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: SpotlyColors.shadow(dark)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    height: 250,
                    color: Colors.grey[900],
                    child: const Icon(LucideIcons.imageOff,
                        color: Colors.white24)),
              ),
              Positioned.fill(
                  child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8)
                  ])))),
              Positioned(
                bottom: 20,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1)),
                    const Row(children: [
                      Icon(LucideIcons.mapPin,
                          color: Color(0xFF2DD4BF), size: 14),
                      SizedBox(width: 5),
                      Text('Bolivia',
                          style: TextStyle(color: Colors.white70, fontSize: 12))
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
