import 'package:flutter/material.dart';
import 'admin_dashboard_content.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isDarkMode = true;
  int _selectedIndex = 0;

  void _onNavTap(int index) => setState(() => _selectedIndex = index);
  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  @override
  Widget build(BuildContext context) {
    // LISTA DE VISTAS FUTURAS (AQUÍ LLAMARÁS A TU FEED O LOGIN)
    final List<Widget> _adminViews = [
      // 0. Dashboard / Feed Principal
      const _ViewPlaceholder(label: "Dashboard: Feed de Actividad Reciente"),

      // 1. Lugares
      const _ViewPlaceholder(label: "Gestión de Lugares Turísticos"),

      // 2. Usuarios
      const _ViewPlaceholder(label: "Control de Usuarios e Influencers"),

      // 3. Reportes
      const _ViewPlaceholder(label: "Reportes y Estadísticas de Bolivia"),
    ];

    return AdminDashboardContent(
      isDarkMode: _isDarkMode,
      selectedIndex: _selectedIndex,
      onToggleTheme: _toggleTheme,
      onNavTap: _onNavTap,
      onSearch: () => debugPrint("Abriendo Buscador Global..."),
      onRedirect: (route) => debugPrint("Redirigiendo a: $route"),

      // EL HIJO DINÁMICO:
      // Usamos IndexedStack para que al cambiar de pestaña no se pierda el scroll
      child: IndexedStack(
        index: _selectedIndex,
        children: _adminViews,
      ),
    );
  }
}

// Widget auxiliar para mantener el espacio limpio hasta que pongas el contenido real
class _ViewPlaceholder extends StatelessWidget {
  final String label;
  const _ViewPlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
