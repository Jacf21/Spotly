import 'package:flutter/material.dart';
import '../../../../core/utils/theme_utils.dart';

// Este es solo para la sección de descripción en la pantalla de publicación
class PostDescriptionInput extends StatefulWidget {
  final Function(String) onDescriptionChanged;

  const PostDescriptionInput({
    super.key, 
    required this.onDescriptionChanged
  });

  @override
  State<PostDescriptionInput> createState() => _PostDescriptionInputState();
}

class _PostDescriptionInputState extends State<PostDescriptionInput> {
  final TextEditingController _controller = TextEditingController();
  final int _maxLength = 2200;

  @override
  void dispose() {
    _controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Detectamos el modo oscuro
    final dark = ThemeUtils.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DESCRIPCIÓN", 
          style: TextStyle(
            fontSize: 12, 
            color: dark ? Colors.white70 : const Color.fromARGB(255, 7, 7, 7), 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          )
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? Colors.white.withOpacity(0.05) : Colors.grey[50], 
            borderRadius: BorderRadius.circular(15),
            // Borde sutil para definir el área
            border: Border.all(
              color: dark ? Colors.white10 : Colors.grey[200]!,
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 3,
                maxLength: _maxLength,
                style: TextStyle(
                  fontSize: 15, 
                  color: dark ? Colors.white : Colors.black
                ),
                decoration: InputDecoration(
                  hintText: "¿Qué hace especial a este rincón de Bolivia?...",
                  hintStyle: TextStyle(
                    color: dark ? Colors.white30 : const Color.fromARGB(255, 201, 200, 200), 
                    fontSize: 14
                  ),
                  border: InputBorder.none, 
                  counterText: "", 
                ),
                onChanged: (value) {
                  setState(() {}); 
                  widget.onDescriptionChanged(value); 
                },
              ),
              // Divisor que se adapta al modo
              Divider(height: 20, color: dark ? Colors.white10 : Colors.grey[200]),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${_controller.text.length} / $_maxLength",
                  style: TextStyle(
                    color: _controller.text.length > (_maxLength * 0.9) 
                        ? Colors.red 
                        : (dark ? Colors.white38 : Colors.grey),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}