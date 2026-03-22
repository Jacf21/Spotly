import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class GuestHomeContent extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final Function(int) onNavItemTapped;
  final Function(String) onGuestAction;
  final int selectedIndex;
  final Widget child;

  const GuestHomeContent({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.onNavItemTapped,
    required this.onGuestAction,
    required this.selectedIndex,
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
            Expanded(child: child),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFF00BCD4)
                : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            size: isSelected ? 26 : 24,
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(top: 4),
            height: 4,
            width: isSelected ? 20 : 0,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plusButton() {
    return GestureDetector(
      onTap: () => onGuestAction('crear contenido'),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF00BCD4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
