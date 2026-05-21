import 'package:image_picker/image_picker.dart';

// Este Helper se encarga de manejar la selección de imágenes tanto para Web como para Móvil, utilizando el paquete image_picker. Proporciona una función genérica que puede ser llamada desde cualquier parte de la aplicación para obtener una imagen del usuario, ya sea desde la cámara o la galería.
class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  // Función genérica para obtener imagen
  static Future<XFile?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70, 
        maxWidth: 1200,
      );
      
      return pickedFile;

    } catch (e) {
      print("Error seleccionando imagen: $e");
    }
    return null;
  }
}