import 'package:flutter/material.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Panel',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: SpotlyColors.text(dark),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'esta parte tendra el total usuarios, total publicaciones, total lugares, publicaciones hoy, usuarios nuevos, lugares destacados y reportes pendientes',
            style: TextStyle(color: SpotlyColors.subText(dark), fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }
}