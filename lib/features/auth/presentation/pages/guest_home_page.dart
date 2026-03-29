import 'package:flutter/material.dart';
import 'guest_home_content.dart';
import 'spotly_ui.dart'; // Asegura acceso a los colores para el Placeholder

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage> {
  bool _isDarkMode = true;
  int _selectedIndex = 0;

  void _onNavItemTapped(int index) => setState(() => _selectedIndex = index);
  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  @override
  Widget build(BuildContext context) {
    // LISTA DE VISTAS PARA EL MODO INVITADO
    final List<Widget> _guestViews = [
      const _GuestPlaceholder(
        title: 'Explora Bolivia',
        subtitle: 'Descubre lugares increíbles sin iniciar sesión.',
      ),
      const _GuestPlaceholder(
          title: 'Spotly Reels', subtitle: 'Próximamente...'),
      const _GuestPlaceholder(
          title: 'Mensajería', subtitle: 'Inicia sesión para chatear.'),
      const _GuestPlaceholder(
          title: 'Tu Perfil', subtitle: 'Accede a tu cuenta de Spotly.'),
    ];

    // LLAMADA AL COMPONENTE ADAPTADO
    return GuestHomeContent(
      isDarkMode: _isDarkMode,
      selectedIndex: _selectedIndex,
      onToggleTheme: _toggleTheme,
      onNavItemTapped: _onNavItemTapped,
      onGuestAction: (action) {
        // Lógica de acciones para invitados (Show Modal, Login, etc.)
        debugPrint("Acción Invitado: $action");
        SpotlyUI.toast(context, "Inicia sesión para $action", _isDarkMode);
      },
      child: IndexedStack(
        index: _selectedIndex,
        children: _guestViews,
      ),
    );
  }
}

class _GuestPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;
  const _GuestPlaceholder({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900, // Black
                color: Color(0xFF2DD4BF)), // Cyan accent
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }
}
