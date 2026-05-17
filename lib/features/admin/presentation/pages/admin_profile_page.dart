import 'package:flutter/material.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Perfil',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: SpotlyColors.text(dark),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aquí irán datos sobre el perfil del administrador',
            style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 14, height: 1.6),
          ),
          // TODO: agregar charts con fl_chart o similar
        ],
      ),
    );
  }
}