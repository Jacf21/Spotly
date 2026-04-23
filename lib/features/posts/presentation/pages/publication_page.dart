import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:spotly/core/utils/locationHelper.dart';
import 'package:spotly/core/widgets/post_image_publication.dart';
import 'package:spotly/core/widgets/description_publication.dart';
import 'package:spotly/core/widgets/location_selector_publication.dart';
import 'package:spotly/core/widgets/setting_publication.dart';
import 'package:spotly/features/posts/data/datasources/subida_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/theme_utils.dart';
import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/themes/spotly_config.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  XFile? _selectedImage;
  String _description = "";
  String _privacy = "Público";
  bool _disableComments = false;
  String _title = "";
  
  // Valor inicial (Cochabamba)
  LatLng _currentLatLng = const LatLng(-17.3935, -66.1570);
  String _locationSubtitle = "Cochabamba";
  String municipio = "";
  
  bool dark = false;
  bool _isLoading = false;
 @override
  Widget build(BuildContext context) {
    //DETECTAMOS EL MODO
    dark = ThemeUtils.isDark(context);

    return AnimatedContainer(
      duration: SpotlyConfig.animShort,
      color: SpotlyColors.bg(dark), // Fondo dinámico
      child: Scaffold(
        //IMPORTANTE: Scaffold transparente para que se vea el color del AnimatedContainer
        backgroundColor: Colors.transparent, 
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: dark ? Colors.white : Colors.black),
            onPressed: () => context.go('/feed'),
          ),
          title: Text(
            "Nueva publicación",
            style: TextStyle(
              color: dark ? Colors.white : Colors.black, 
              fontWeight: FontWeight.bold, 
              fontSize: 18
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PostImagePicker(
                  onImageSelected: (XFile) => setState(() => _selectedImage = XFile),
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "TÍTULO: NOMBRE DEL LUGAR",
                style: TextStyle(
                  fontSize: 12, 
                  color: dark ? Colors.white70 : Colors.black87, // Color dinámico
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1.2
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                onChanged: (val) => _title = val,
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w500,
                  color: dark ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "Ej: Cascada de Pairumani",
                  hintStyle: TextStyle(color: dark ? Colors.white38 : Colors.grey),
                  border: InputBorder.none,
                ),
              ),
              
              const SizedBox(height: 24),

              PostDescriptionInput(
                onDescriptionChanged: (text) => _description = text,
              ),

              const SizedBox(height: 24),
              PostLocationSelector(
                onLocationChanged: (coords, deptoName, city) {
                  setState(() {
                    _currentLatLng = coords;
                    _locationSubtitle = deptoName;
                    municipio = city;
                  });
                },
              ),
              const SizedBox(height: 24),

              PostSettingsPanel(
                onPrivacyChanged: (val) => _privacy = val,
                onCommentsDisabledChanged: (val) => _disableComments = val,
              ),
              
              const SizedBox(height: 40), 
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpotlyColors.accent(dark),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Publicar ahora", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ]
          )
        )
      ),
    );
  }

  Future<void> _validateAndSubmit() async {
    
    //Validaciones de UI
    if (_selectedImage == null) {
      _showErrorSnackBar("¡Por favor selecciona una foto de tu aventura!");
      return;
    }
    if (_title.isEmpty) {
      _showErrorSnackBar("El nombre del lugar es obligatorio");
      return;
    }

    String privacidadDB = "public";
    if (_privacy == "Amigos") privacidadDB = "friends";
    if (_privacy == "Privado") privacidadDB = "private";

    bool permiteComentarios = !_disableComments;
    setState(() => _isLoading = true);
    try {
      final remoteDataSource = PostRemoteDataSourceImpl(Supabase.instance.client);
      int idParaDB = LocationHelper.getDeptoIdByName(_locationSubtitle);

      //Subida con datos REALES del estado del widget
      await remoteDataSource.uploadPost(
        imageFile: _selectedImage!,
        title: _title,
        description: _description,
        deptoId: idParaDB,
        city: municipio, 
        lat: _currentLatLng.latitude,
        lng: _currentLatLng.longitude, 
        privacidad: privacidadDB,
        permiteComen: permiteComentarios,
      );
      if (mounted) {
        _showSuccessSnackBar("✅ ¡Tu aventura se ha publicado con éxito!");

        //volvemos al feed para ver cambios despues de publicar
        context.go('/feed');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar("❌ Error al publicar: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:SpotlyColors.accent(dark),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}