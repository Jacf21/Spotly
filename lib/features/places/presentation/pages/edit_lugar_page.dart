import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';
import 'package:spotly/core/utils/spotly_ui.dart';
import '../../data/models/lugar_detalle_model.dart';
import '../../data/datasources/lugar_remote_datasource.dart';
import '../../data/repositories/lugar_repository.dart';

class EditLugarPage extends StatefulWidget {
  final LugarDetalleModel lugar;

  const EditLugarPage({super.key, required this.lugar});

  @override
  State<EditLugarPage> createState() => _EditLugarPageState();
}

class _EditLugarPageState extends State<EditLugarPage> {
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final TextEditingController _resumenController;
  late final TextEditingController _alturaController;
  late final TextEditingController _climaController;
  late final TextEditingController _mejorEpocaController;
  late final TextEditingController _informacionUtilController;
  late final TextEditingController _categoriaController;

  bool _isLoading = false;
  late final LugarRepository _repo;

  @override
  void initState() {
    super.initState();

    // Inicializar repositorio con manejo de errores
    try {
      _repo = LugarRepository(LugarRemoteDatasource(Supabase.instance.client));
    } catch (e) {
      debugPrint("Error inicializando repositorio: $e");
      // Fallback: crear con cliente por defecto
      _repo = LugarRepository(LugarRemoteDatasource(Supabase.instance.client));
    }

    // Inicializar controladores con valores seguros
    _nombreController =
        TextEditingController(text: _safeString(widget.lugar.nombre));
    _descripcionController =
        TextEditingController(text: _safeString(widget.lugar.descripcion));
    _resumenController =
        TextEditingController(text: _safeString(widget.lugar.resumen));
    _alturaController =
        TextEditingController(text: widget.lugar.alturaMsnm?.toString() ?? '');
    _climaController =
        TextEditingController(text: _safeString(widget.lugar.climaRecomendado));
    _mejorEpocaController = TextEditingController(
        text: _safeString(widget.lugar.mejorEpocaVisitar));
    _informacionUtilController =
        TextEditingController(text: _safeString(widget.lugar.informacionUtil));
    _categoriaController =
        TextEditingController(text: _safeString(widget.lugar.categoria));
  }

  // Método de seguridad para strings nulos
  String _safeString(String? value) => value ?? '';

  @override
  void dispose() {
    // Dispose seguro
    _safeDispose(_nombreController);
    _safeDispose(_descripcionController);
    _safeDispose(_resumenController);
    _safeDispose(_alturaController);
    _safeDispose(_climaController);
    _safeDispose(_mejorEpocaController);
    _safeDispose(_informacionUtilController);
    _safeDispose(_categoriaController);
    super.dispose();
  }

  void _safeDispose(TextEditingController? controller) {
    try {
      controller?.dispose();
    } catch (e) {
      debugPrint("Error al disponer controller: $e");
    }
  }

  String _safeTrim(String text) => text.isEmpty ? '' : text.trim();

  int? _safeParseInt(String value) {
    if (value.isEmpty) return null;
    try {
      return int.tryParse(value);
    } catch (e) {
      return null;
    }
  }

  Future<void> _guardarCambios() async {
    // Validación con recuperación
    final nombreLimpio = _safeTrim(_nombreController.text);
    if (nombreLimpio.isEmpty) {
      await _showSafeToast("El nombre es obligatorio");
      return;
    }

    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Construir data con valores seguros
      // ⚠️ IMPORTANTE: NO incluir nombre_categoria ni nombre_departamento
      // La tabla usa id_categoria y id_departamento (no se editan aquí)
      final data = {
        'nombre_lugar': nombreLimpio,
        'descripcion': _safeTrim(_descripcionController.text).isEmpty
            ? null
            : _safeTrim(_descripcionController.text),
        'resumen': _safeTrim(_resumenController.text).isEmpty
            ? null
            : _safeTrim(_resumenController.text),
        'altura_msnm': _safeParseInt(_safeTrim(_alturaController.text)),
        'clima_recomendado': _safeTrim(_climaController.text).isEmpty
            ? null
            : _safeTrim(_climaController.text),
        'mejor_epoca_visitar': _safeTrim(_mejorEpocaController.text).isEmpty
            ? null
            : _safeTrim(_mejorEpocaController.text),
        'informacion_util': _safeTrim(_informacionUtilController.text).isEmpty
            ? null
            : _safeTrim(_informacionUtilController.text),
        // Mantener la imagen actual (no se puede editar)
        'foto_portada_url': widget.lugar.fotoPortadaUrl,
      };

      print("Enviando datos para actualizar: $data"); // Debug

      // Ejecutar actualización con timeout
      await _repo.actualizarLugar(widget.lugar.id, data).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception("Tiempo de espera agotado"),
          );

      if (mounted) {
        await _showSafeToast("✅ Lugar actualizado correctamente");
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error guardando: $e");
      if (mounted) {
        await _showSafeToast(
            "❌ Error al actualizar: ${_getUserFriendlyMessage(e)}");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getUserFriendlyMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('network')) return "Sin conexión a internet";
    if (errorStr.contains('timeout')) return "El servidor no responde";
    if (errorStr.contains('permission')) return "No tienes permisos";
    if (errorStr.contains('auth')) return "Sesión expirada";
    if (errorStr.contains('null value'))
      return "Hay campos obligatorios vacíos";
    return "Intenta nuevamente";
  }

  Future<void> _showSafeToast(String message) async {
    try {
      if (mounted) {
        SpotlyUI.toast(context, message);
      }
    } catch (e) {
      debugPrint("Error mostrando toast: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      appBar: AppBar(
        title: Text(
          'Editar Lugar Turístico',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: SpotlyColors.text(dark),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: SpotlyColors.text(dark)),
          onPressed: () {
            try {
              Navigator.pop(context);
            } catch (e) {
              debugPrint("Error al cerrar: $e");
            }
          },
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.save, color: SpotlyColors.accent(dark)),
            onPressed: _isLoading ? null : _guardarCambios,
            tooltip: 'Guardar cambios',
          ),
        ],
        backgroundColor: SpotlyColors.bg(dark),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vista previa de la imagen actual (solo lectura)
              if (_safeString(widget.lugar.fotoPortadaUrl).isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "IMAGEN ACTUAL",
                        style: TextStyle(
                          color: SpotlyColors.accent(dark),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.lugar.fotoPortadaUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 180,
                            color: SpotlyColors.card(dark),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image,
                                    size: 48,
                                    color: SpotlyColors.subText(dark)),
                                const SizedBox(height: 8),
                                Text(
                                  "No se pudo cargar la imagen",
                                  style: TextStyle(
                                      color: SpotlyColors.subText(dark)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 14, color: SpotlyColors.subText(dark)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "La imagen de portada no se puede editar desde aquí",
                              style: TextStyle(
                                fontSize: 11,
                                color: SpotlyColors.subText(dark),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              _buildSectionTitle(dark, "INFORMACIÓN BÁSICA"),
              _buildTextField(
                dark,
                "Nombre del lugar *",
                _nombreController,
                icon: Icons.location_city,
              ),
              const SizedBox(height: 15),
              _buildTextField(
                dark,
                "Resumen corto",
                _resumenController,
                icon: Icons.summarize,
                maxLines: 2,
                hintText: "Breve descripción del lugar (máx. 200 caracteres)",
              ),
              const SizedBox(height: 15),
              _buildTextField(
                dark,
                "Descripción completa",
                _descripcionController,
                icon: Icons.description,
                maxLines: 5,
                hintText:
                    "Describe en detalle el lugar, su historia, atractivos, etc.",
              ),
              const SizedBox(height: 25),

  

              _buildSectionTitle(dark, "CARACTERÍSTICAS"),
              _buildTextField(
                dark,
                "Categoría (solo información, no editable en BD)",
                _categoriaController,
                icon: Icons.category,
                hintText: "Ej: Montaña, Playa, Museo, Parque Nacional",
                enabled: false, // Campo solo lectura
              ),
              const SizedBox(height: 15),
              _buildTextField(
                dark,
                "Altura (msnm)",
                _alturaController,
                icon: Icons.height,
                keyboardType: TextInputType.number,
                hintText: "Ej: 3640",
              ),
              const SizedBox(height: 15),
              _buildTextField(
                dark,
                "Clima recomendado",
                _climaController,
                icon: Icons.wb_sunny,
                hintText: "Ej: Templado, Lluvioso, Seco",
              ),
              const SizedBox(height: 15),
              _buildTextField(
                dark,
                "Mejor época para visitar",
                _mejorEpocaController,
                icon: Icons.calendar_today,
                hintText: "Ej: Abril a Octubre",
              ),
              const SizedBox(height: 25),

              _buildSectionTitle(dark, "INFORMACIÓN ADICIONAL"),
              _buildTextField(
                dark,
                "Información útil",
                _informacionUtilController,
                icon: Icons.info,
                maxLines: 3,
                hintText: "Consejos, recomendaciones, horarios, precios, etc.",
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(bool dark, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          color: SpotlyColors.accent(dark),
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField(
    bool dark,
    String label,
    TextEditingController controller, {
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        color: enabled ? SpotlyColors.text(dark) : SpotlyColors.subText(dark),
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: enabled
              ? SpotlyColors.subText(dark)
              : SpotlyColors.subText(dark).withOpacity(0.6),
          fontSize: 14,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: SpotlyColors.subText(dark).withOpacity(0.5),
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
        prefixIcon: icon != null
            ? Icon(icon,
                color: enabled
                    ? SpotlyColors.accent(dark)
                    : SpotlyColors.subText(dark),
                size: 22)
            : null,
        filled: true,
        fillColor: dark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: SpotlyColors.accent(dark), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
