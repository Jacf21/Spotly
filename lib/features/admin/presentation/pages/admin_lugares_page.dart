import 'package:flutter/material.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';

class AdminLugaresPage extends StatefulWidget {
  const AdminLugaresPage({super.key});

  @override
  State<AdminLugaresPage> createState() => _AdminLugaresPageState();
}

class _AdminLugaresPageState extends State<AdminLugaresPage> {

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Lugares',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: SpotlyColors.text(dark),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aquí irán datos sobre los lugares reportes y edicion de datos y mas',
            style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 14, height: 1.6),
          ),
          // TODO: agregar charts con fl_chart o similar
        ],
      ),
    );
  }
}