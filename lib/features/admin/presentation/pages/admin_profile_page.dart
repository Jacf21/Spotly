import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/utils/theme_utils.dart';

import '../bloc/admin_profile_bloc.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {

  final nombresCtrl = TextEditingController();
  final apellidosCtrl = TextEditingController();
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),

      body: BlocConsumer<AdminProfileBloc, AdminProfileState>(
        builder: (context, state) {
          if (state is AdminProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final profileState = switch (state) {
            AdminProfileLoaded s => s,
            AdminProfileError s when s.profile != null =>
                AdminProfileLoaded(s.profile!),
            _ => null,
          };

          if (profileState != null) {
            if (state is AdminProfileLoaded) {
              final profile = state.profile;
              nombresCtrl.text = profile['nombres'] ?? '';
              apellidosCtrl.text = profile['apellidos'] ?? '';
              usernameCtrl.text = profile['nombre_usuario'] ?? '';
            }
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Perfil administrador',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: SpotlyColors.text(dark),
                  ),
                ),
                const SizedBox(height: 24),
                _buildField(
                  controller: nombresCtrl,
                  label: 'Nombres',
                  dark: dark,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: apellidosCtrl,
                  label: 'Apellidos',
                  dark: dark,
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: usernameCtrl,
                  label: 'Nombre de usuario',
                  dark: dark,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminProfileBloc>().add(
                      OnUpdateAdminProfile(
                        nombres: nombresCtrl.text.trim(),
                        apellidos: apellidosCtrl.text.trim(),
                        username: usernameCtrl.text.trim(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpotlyColors.accent(dark),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar cambios'),
                ),
                const SizedBox(height: 40),
                Text(
                  'Cambiar contraseña',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: SpotlyColors.text(dark),
                  ),
                ),
                const SizedBox(height: 16),
                _buildField(
                  controller: passwordCtrl,
                  label: 'Nueva contraseña',
                  obscure: true,
                  dark: dark,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AdminProfileBloc>().add(
                      OnChangeAdminPassword(
                        passwordCtrl.text.trim(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpotlyColors.accent(dark),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Actualizar contraseña'),
                ),
              ],
            );
          }

          return const SizedBox();
        }, 
        listener: (context, state) {

          if (state is AdminProfileError) {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  // Método auxiliar para construir los campos de texto
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    required bool dark,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: SpotlyColors.text(dark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: SpotlyColors.subText(dark)),
        filled: true,
        fillColor: dark ? const Color(0xFF1E293B) : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SpotlyColors.subText(dark).withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SpotlyColors.subText(dark).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SpotlyColors.accent(dark), width: 2),
        ),
      ),
    );
  }
}