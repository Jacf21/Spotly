import 'package:flutter/material.dart';
import 'admin_dashboard_content.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isDarkMode = true;
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _showToast('Panel de administración');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showRedirect(String message) {
    _showToast('$message (Próximamente)');
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _onSearch() {
    _showRedirect('🔍 Buscador admin');
  }

  @override
  Widget build(BuildContext context) {
    return AdminDashboardContent(
      isDarkMode: _isDarkMode,
      isLoading: _isLoading,
      selectedIndex: _selectedIndex,
      onToggleTheme: _toggleTheme,
      onNavTap: _onNavItemTapped,
      onSearch: _onSearch,
      onRedirect: _showRedirect,
      child: Text("contenido aqui"),
    );
  }
}
