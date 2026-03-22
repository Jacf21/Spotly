import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UserHomeContent extends StatelessWidget {
  final bool isDarkMode;
  final int selectedIndex;
  final VoidCallback onToggleTheme;
  final Function(int) onNavItemTapped;
  final VoidCallback onSearch;
  final VoidCallback onCreate;
  final Widget child;

  const UserHomeContent({
    super.key,
    required this.isDarkMode,
    required this.selectedIndex,
    required this.onToggleTheme,
    required this.onNavItemTapped,
    required this.onSearch,
    required this.onCreate,
    required this.child,
  });

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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: isDarkMode ? const Color(0xFF111827) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SPOTLY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Color(0xFF00BCD4),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            isDarkMode ? LucideIcons.sun : LucideIcons.moon,
                            key: ValueKey(isDarkMode),
                          ),
                        ),
                        onPressed: onToggleTheme,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.search),
                        onPressed: onSearch,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: child),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: isDarkMode ? const Color(0xFF111827) : Colors.white,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(LucideIcons.layoutGrid, 0),
                    _navItem(LucideIcons.clapperboard, 1),
                    GestureDetector(
                      onTap: onCreate,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                    _navItem(LucideIcons.send, 2),
                    _navItem(LucideIcons.user, 3),
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
    final isActive = index == selectedIndex;

    return GestureDetector(
      onTap: () => onNavItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? const Color(0xFF00BCD4)
                : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            size: isActive ? 26 : 24,
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(top: 4),
            height: 4,
            width: isActive ? 20 : 0,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF00BCD4) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
