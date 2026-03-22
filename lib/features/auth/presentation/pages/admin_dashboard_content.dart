import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AdminDashboardContent extends StatelessWidget {
  final bool isDarkMode;
  final bool isLoading;
  final int selectedIndex;
  final VoidCallback onToggleTheme;
  final Function(int) onNavTap;
  final VoidCallback onSearch;
  final Function(String) onRedirect;

  const AdminDashboardContent({
    super.key,
    required this.isDarkMode,
    required this.isLoading,
    required this.selectedIndex,
    required this.onToggleTheme,
    required this.onNavTap,
    required this.onSearch,
    required this.onRedirect,
  });

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor:
            isDarkMode ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      duration: const Duration(milliseconds: 300),
      child: Scaffold(
        backgroundColor:
            isDarkMode ? const Color(0xFF0A0F1A) : const Color(0xFFF8FAFF),
        body: Column(
          children: [
            // 🔝 TOP BAR ADMIN
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: isDarkMode ? const Color(0xFF111827) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'SPOTLY',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9800),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Text(
                          'ADMIN',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                                scale: animation, child: child);
                          },
                          child: Icon(
                            isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                            key: ValueKey(isDarkMode),
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        onPressed: onToggleTheme,
                      ),
                      IconButton(
                        icon: Icon(
                          LucideIcons.search,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                        onPressed: () {
                          _showMessage(context, '🔍 Búsqueda administrativa');
                          onSearch();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🧠 CONTENIDO
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF00BCD4),
                        ),
                      ),
                    )
                  : Container(),
            ),
            // 🔻 NAV ADMIN
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: isDarkMode ? const Color(0xFF111827) : Colors.white,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(LucideIcons.layoutDashboard, 0),
                    _navItemCustom(
                      LucideIcons.mapPin,
                      () => _showMessage(context, '📍 Gestión de lugares'),
                      label: 'Lugares',
                    ),
                    _navItemCustom(
                      LucideIcons.users,
                      () => _showMessage(context, '👥 Gestión de usuarios'),
                      label: 'Usuarios',
                    ),
                    _navItemCustom(
                      LucideIcons.flag,
                      () => _showMessage(context, '🚩 Gestión de reportes'),
                      label: 'Reportes',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    final isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () => onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isActive
                    ? const Color(0xFF00BCD4)
                    : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                size: isActive ? 26 : 24,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              width: isActive ? 20 : 0,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF00BCD4) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItemCustom(IconData icon, VoidCallback onTap, {String? label}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 24,
              ),
            ),
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  child: Text(label),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
