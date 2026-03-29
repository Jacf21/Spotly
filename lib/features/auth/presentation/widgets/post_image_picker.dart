import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/image_helper.dart';

class PostImagePicker extends StatefulWidget {
  // Callback para avisar a la pantalla principal que ya tenemos una imagen
  final Function(File) onImageSelected;

  const PostImagePicker({super.key, required this.onImageSelected});

  @override
  State<PostImagePicker> createState() => _PostImagePickerState();
}

class _PostImagePickerState extends State<PostImagePicker> {
  File? _image;

  // Método interno para gestionar la selección
  Future<void> _handleImagePick(ImageSource source) async {
    final File? selected = await ImageHelper.pickImage(source);
    if (selected != null) {
      setState(() => _image = selected);
      widget.onImageSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1, // Mantiene el formato cuadrado de la imagen
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
          image: _image != null
              ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
              : null,
        ),
        child: Stack(
          children: [
            if (_image == null)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Añade una foto de tu aventura", 
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
            
            // Botones flotantes (Cámara y Galería)
            Positioned(
              bottom: 12,
              right: 12,
              child: Row(
                children: [
                  _buildActionButton(Icons.camera_alt, () => _handleImagePick(ImageSource.camera)),
                  const SizedBox(width: 8),
                  _buildActionButton(Icons.photo_library, () => _handleImagePick(ImageSource.gallery)),
                ],
              ),
            ),

            // Botón para borrar si ya hay una foto
            if (_image != null)
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _image = null),
                  child: const CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 18,
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget privado para los botones circulares
  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, color: Colors.cyan, size: 24),
      ),
    );
  }
}