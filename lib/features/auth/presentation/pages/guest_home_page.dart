import 'package:flutter/material.dart';

import 'guest_home_content.dart';
import '../../../../core/utils/spotly_ui.dart';

class GuestHomePage extends StatefulWidget {
  final Widget child;

  const GuestHomePage({
    super.key,
    required this.child,
  });

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  bool _isDarkMode = true;

  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  @override
  Widget build(BuildContext context) {
    return GuestHomeContent(
      isDarkMode: _isDarkMode,
      onToggleTheme: _toggleTheme,
      onGuestAction: (action) {
        debugPrint("Acción Invitado: $action");

        SpotlyUI.toast(
          context,
          "Inicia sesión para $action",
        );
      },
      child: widget.child,
    );
  }
}