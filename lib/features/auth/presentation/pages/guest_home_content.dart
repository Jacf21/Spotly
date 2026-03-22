import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GuestHomeContent extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Function(int) onNavItemTapped;
  final Function(String) onGuestAction;
  final int selectedIndex;

  const GuestHomeContent({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onNavItemTapped,
    required this.onGuestAction,
    required this.selectedIndex,
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
            // TOP BAR
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00BCD4),
                    ),
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
                          ),
                        ),
                        onPressed: onToggleTheme,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.search),
                        onPressed: () => onGuestAction('buscar destinos'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // CONTENIDO
            Expanded(
              child: Container(),
            ),
            // NAV BAR
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: isDarkMode ? const Color(0xFF111827) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _item(LucideIcons.home, 'Inicio', 0),
                  _item(LucideIcons.clapperboard, 'Reels', 1,
                      action: 'ver reels'),
                  _plusButton(),
                  _item(LucideIcons.send, 'Mensajes', 2,
                      action: 'ver mensajes'),
                  _item(LucideIcons.user, 'Perfil', 3, action: 'ver perfil'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, int index, {String? action}) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (action != null) {
          onGuestAction(action);
        } else {
          onNavItemTapped(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF00BCD4) : Colors.grey,
                size: isSelected ? 26 : 24,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? const Color(0xFF00BCD4)
                    : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _plusButton() {
    return GestureDetector(
      onTap: () => onGuestAction('crear contenido'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF00BCD4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00BCD4).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
