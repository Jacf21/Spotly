import 'package:flutter/material.dart';
import 'user_home_content.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage>
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

    // Simulación carga
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

    if (index == 0) {
      _showToast('✨ Bienvenido a Spotly');
    } else {
      _showToast(_getNavItemName(index));
    }
  }

  String _getNavItemName(int index) {
    switch (index) {
      case 1:
        return '🎬 Reels';
      case 2:
        return '💬 Mensajes';
      case 3:
        return '👤 Perfil';
      default:
        return '';
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$message (Próximamente)')),
    );
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _onSearchPressed() {
    _showToast('🔍 Buscando destinos');
  }

  void _onCreatePressed() {
    _showToast('📸 Crear publicación');
  }

  @override
  Widget build(BuildContext context) {
    return UserHomeContent(
      isDarkMode: _isDarkMode,
      //isLoading: _isLoading,
      selectedIndex: _selectedIndex,
      onToggleTheme: _toggleTheme,
      onNavItemTapped: _onNavItemTapped,
      onSearch: _onSearchPressed,
      onCreate: _onCreatePressed,
      child: Text("Contenido aqui"), 
    );
  }
}
