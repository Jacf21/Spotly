import 'package:flutter/material.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';

class AdminUsuariosPage extends StatefulWidget {
  const AdminUsuariosPage({super.key});

  @override
  State<AdminUsuariosPage> createState() => _AdminUsuariosPageState();
}

class _AdminUsuariosPageState extends State<AdminUsuariosPage> {

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Usuarios',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: SpotlyColors.text(dark),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Aquí irán datos sobre los usuarios: seguidores seguidos, cantidad de publicaiones, banear cuentas, eliminar cuentas definitivamente y mas',
            style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}