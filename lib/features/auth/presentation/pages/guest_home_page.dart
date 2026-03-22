import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'guest_home_content.dart';

class GuestHomePage extends StatefulWidget {
  const GuestHomePage({super.key});

  @override
  State<GuestHomePage> createState() => _GuestHomePageState();
}

class _GuestHomePageState extends State<GuestHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isDarkMode = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
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
    _showToast('Bienvenido a Spotly');
  }

  void _triggerGuest(String action) {
    _showModal('🔐 ¡Descubre más!', 'Inicia sesión para $action');
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showModal(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GuestHomeContent(
      isDarkMode: _isDarkMode,
      onToggleTheme: _toggleTheme,
      onNavItemTapped: _onNavItemTapped,
      onGuestAction: _triggerGuest,
      selectedIndex: _selectedIndex,
    );
  }
}
