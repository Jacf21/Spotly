import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import '../../../../core/utils/imageHelper.dart';
import '../../../../core/utils/theme_utils.dart';

// Este es solo para la sección de imagen en la pantalla de publicación
class PostImagePicker extends StatefulWidget {
  final Function(XFile) onImageSelected;

  const PostImagePicker({super.key, required this.onImageSelected});

  @override
  State<PostImagePicker> createState() => _PostImagePickerState();
}

class _PostImagePickerState extends State<PostImagePicker> {
  XFile? _image;

  Future<void> _handleImagePick(ImageSource source) async {
    final XFile? selected = (await ImageHelper.pickImage(source)) as XFile?;
    if (selected != null) {
      setState(() {
        _image = selected;
      });
      widget.onImageSelected(selected);
    }
  }

  @override
  Widget build(BuildContext context) {

    //Detectamos el modo oscuro
    final dark = ThemeUtils.isDark(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        //Ajustamos la relación de aspecto según el ancho disponible (aun no se esta usando)
        double dynamicRatio = constraints.maxWidth > 600 ? 21 / 9 : 16 / 9;

        return AspectRatio(
          aspectRatio: 1,
          child: Container(
            width: double.infinity, 
            clipBehavior: Clip.antiAlias, 
            decoration: BoxDecoration(
              // Fondo dinámico
              color: dark ? Colors.white.withOpacity(0.05) : Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: dark ? Colors.white10 : Colors.grey[300]!,
              ),
              image: _image != null
                  ? DecorationImage(
                      // En Web usamos NetworkImage, en Móvil FileImage
                      image: kIsWeb 
                          ? NetworkImage(_image!.path)
                          : FileImage(File(_image!.path)) as ImageProvider,
                      fit: BoxFit.fill,
                    )
                  : null,
            ),
            child: Stack(
              children: [

                // Placeholder cuando no hay imagen
                if (_image == null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined, 
                          size: 50, 
                          color: dark ? Colors.white38 : Colors.grey
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Añade una foto", 
                          style: TextStyle(
                            color: dark ? Colors.white38 : Colors.grey,
                            fontWeight: FontWeight.w500
                          )
                        ),
                      ],
                    ),
                  ),
                
                //Botones de selección (Cámara/Galería)
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Row(
                    children: [
                      _buildActionButton(Icons.camera_alt, dark, () => _handleImagePick(ImageSource.camera)),
                      const SizedBox(width: 10),
                      _buildActionButton(Icons.photo_library, dark, () => _handleImagePick(ImageSource.gallery)),
                    ],
                  ),
                ),
                
                // Botón para borrar la imagen seleccionada
                if (_image != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => setState(() => _image = null),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, bool dark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: dark ? Colors.grey[900] : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black45 : Colors.black12, 
              blurRadius: 8,
              offset: const Offset(0, 4)
            )
          ],
        ),
        child: Icon(
          icon, 
          color: SpotlyColors.accent(dark),
          size: 24
        ),
      ),
    );
  }
}