import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/post_image_picker.dart';
import '../widgets/post_description.dart';
import '../widgets/post_location_selector.dart';
import '../widgets/post_settings_panel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/features/auth/data/datasources/subida_storage.dart';
import 'package:spotly/features/auth/data/repositories/post_repository_impl.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  File? _selectedImage;
  String _description = "";
  String _privacy = "Público";
  bool _disableComments = false;
  String _title = "";
  
  //VARIABLE DE ESTADO PARA LA CARGA
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text("Nueva publicación", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            PostImagePicker(
              onImageSelected: (file) => setState(() => _selectedImage = file),
            ),
            const SizedBox(height: 24),

            const Text(
              "TÍTULO: NOMBRE DEL LUGAR",
              style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 6, 6, 6), fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: (val) => _title = val,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "Ej: Cascada de Pairumani",
              ),
            ),
            
            PostDescriptionInput(
              onDescriptionChanged: (text) => _description = text,
            ),
            
            const SizedBox(height: 24),
            const PostLocationSelector(),
            const SizedBox(height: 24),
            
            PostSettingsPanel(
              onPrivacyChanged: (val) => _privacy = val,
              onCommentsDisabledChanged: (val) => _disableComments = val,
            ),
            
            const SizedBox(height: 40),
            
            //BOTÓN CON LÓGICA DE CARGA
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _validateAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
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
          ],
        ),
      ),
    );
  }

  //FUNCIÓN DE SUBIDA INTEGRADA
  Future<void> _validateAndSubmit() async {
    // Validaciones básicas
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Por favor selecciona una foto de tu aventura!")),
      );
      return;
    }
    if (_title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre del lugar es obligatorio")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final remoteDataSource = PostRemoteDataSourceImpl(Supabase.instance.client);
      
      await remoteDataSource.uploadPost(
        imageFile: _selectedImage!,
        title: _title,
        description: _description,
        deptoId: 3,
        lat: -17.3935, 
        lng: -66.1570,
      );

      if (mounted) {
        // MENSAJE DE ÉXITO
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ ¡Tu aventura se ha publicado con éxito!"),
            backgroundColor: Colors.green, 
            behavior: SnackBarBehavior.floating,
          ),
        );

        _resetForm(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error al publicar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  void _resetForm() {
    setState(() {
      _selectedImage = null; 
      _title = "";           
      _description = "";     
    });
    
  }
}