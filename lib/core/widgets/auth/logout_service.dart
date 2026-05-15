import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../context/auth_context.dart';
import '../../themes/spotly_colors.dart';

class LogoutService {
  static Future<void> logout({
    required BuildContext context,
    required bool dark,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SpotlyColors.bg(dark),

        title: Text(
          "Cerrar sesión",
          style: TextStyle(
            color: SpotlyColors.text(dark),
          ),
        ),

        content: Text(
          "¿Estás seguro que deseas salir?",
          style: TextStyle(
            color: SpotlyColors.subText(dark),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              "Cancelar",
              style: TextStyle(
                color: SpotlyColors.subText(dark),
              ),
            ),
          ),

          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Salir",
              style: TextStyle(
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final auth = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      auth.logout();

      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}