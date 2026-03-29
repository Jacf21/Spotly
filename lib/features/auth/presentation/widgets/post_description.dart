import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "DESCRIPCIÓN", 
          style: TextStyle(
            fontSize: 12, 
            color: Color.fromARGB(255, 7, 7, 7), 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          )
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50], // Un fondo muy sutil
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 3,
                maxLength: _maxLength,
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: "¿Qué hace especial a este rincón de Bolivia?...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none, // Quitamos la línea fea de abajo
                  counterText: "", 
                ),
                onChanged: (value) {
                  setState(() {}); // Para actualizar el contador visual
                  widget.onDescriptionChanged(value); 
                },
              ),
              const Divider(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "${_controller.text.length} / $_maxLength",
                  style: TextStyle(
                    color: _controller.text.length > (_maxLength * 0.9) 
                        ? Colors.red 
                        : Colors.grey,
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