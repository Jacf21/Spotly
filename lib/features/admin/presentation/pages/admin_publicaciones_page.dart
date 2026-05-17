import 'package:flutter/material.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';

class AdminPublicacionesPage extends StatefulWidget {
  const AdminPublicacionesPage({super.key});

  @override
  State<AdminPublicacionesPage> createState() => _AdminPublicacionesPageState();
}

class _AdminPublicacionesPageState extends State<AdminPublicacionesPage> {

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Publicaciones',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: SpotlyColors.text(dark),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aquí irán datos sobre las publicaiones: lista de reportes, ocultar publicaion, estadisticas sobre las publicaciones y mas',
            style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}