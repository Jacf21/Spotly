import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/widgets/common/spotly_card.dart';
import '../../../../core/widgets/interactive/spotly_interactive.dart';
import '../../../../core/utils/spotly_ui.dart';
import '../../../../core/utils/theme_utils.dart';
import '../bloc/profile_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- Controladores de Perfil ---
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  // --- Controladores de Seguridad ---
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isUpdatingPass = false;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      context.read<ProfileBloc>().add(OnFetchProfile(user.id));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  /// 🔐 Lógica de Cambio de Contraseña con Validación de Clave Actual
  Future<void> _handleUpdatePassword() async {
    final current = _currentPassController.text.trim();
    final next = _newPassController.text.trim();
    final confirm = _confirmPassController.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      SpotlyUI.toast(
          context, "Por favor, completa todos los campos de seguridad");
      return;
    }

    if (next != confirm) {
      SpotlyUI.toast(
          context, "La nueva contraseña no coincide con la confirmación");
      return;
    }

    if (next.length < 6) {
      SpotlyUI.toast(
          context, "La nueva contraseña debe tener al menos 6 caracteres");
      return;
    }

    setState(() => _isUpdatingPass = true);

    try {
      // 1. Re-autenticamos al usuario para validar su contraseña actual
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) return;

      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: current,
      );

      // 2. Si la re-autenticación funciona, procedemos al cambio
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: next),
      );

      SpotlyUI.toast(context, "✨ Contraseña actualizada con éxito");
      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();
    } on AuthException catch (e) {
      SpotlyUI.toast(context, "Contraseña actual incorrecta o error de sesión");
    } catch (e) {
      SpotlyUI.toast(context, "Error al procesar el cambio");
    } finally {
      if (mounted) setState(() => _isUpdatingPass = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          SpotlyUI.toast(context, "✨ Datos actualizados");
        }
        if (state is ProfileError) {
          SpotlyUI.toast(context, state.message);
        }
        if (state is ProfileLoaded) {
          // Lógica de limpieza para el error de registro mediocre
          final cleanName =
              state.user.nombres.contains('@') ? "" : state.user.nombres;

          if (_nameController.text.isEmpty) _nameController.text = cleanName;
          if (_lastNameController.text.isEmpty)
            _lastNameController.text = state.user.apellidos;
          if (_usernameController.text.isEmpty)
            _usernameController.text = state.user.nombreUsuario;
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading && _nameController.text.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            children: [
              // --- SECCIÓN: DATOS PERSONALES ---
              SpotlyCrystalCard(
                dark: dark,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Hero(
                        tag: 'profile_pic',
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor:
                              SpotlyColors.accent(dark).withOpacity(0.1),
                          child: Icon(LucideIcons.user,
                              size: 40, color: SpotlyColors.accent(dark)),
                        ),
                      )
                          .animate()
                          .scale(duration: 400.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 30),
                      _buildInput(
                          "Nombres", LucideIcons.user, _nameController, dark),
                      const SizedBox(height: 15),
                      _buildInput("Apellidos", LucideIcons.userCheck,
                          _lastNameController, dark),
                      const SizedBox(height: 15),
                      _buildInput("Nombre de Usuario", LucideIcons.atSign,
                          _usernameController, dark),
                      const SizedBox(height: 15),
                      _buildInput("Correo (No editable)", LucideIcons.mail,
                          _emailController, dark,
                          enabled: false),
                      const SizedBox(height: 35),
                      state is ProfileLoading
                          ? const CircularProgressIndicator()
                          : _buildSaveButton(dark),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- SECCIÓN: SEGURIDAD (SIEMPRE ABIERTA) ---
              SpotlyCrystalCard(
                dark: dark,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SEGURIDAD Y CONTRASEÑA",
                        style: TextStyle(
                          color: SpotlyColors.text(dark),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInput("Contraseña Actual", LucideIcons.key,
                          _currentPassController, dark,
                          obscure: true),
                      const SizedBox(height: 15),
                      _buildInput("Nueva Contraseña", LucideIcons.lock,
                          _newPassController, dark,
                          obscure: true),
                      const SizedBox(height: 15),
                      _buildInput("Confirmar Nueva Contraseña",
                          LucideIcons.shieldCheck, _confirmPassController, dark,
                          obscure: true),
                      const SizedBox(height: 25),
                      _isUpdatingPass
                          ? const Center(child: CircularProgressIndicator())
                          : SpotlyInteractive(
                              onTap: _handleUpdatePassword,
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: SpotlyColors.accent(dark)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: SpotlyColors.accent(dark)
                                          .withOpacity(0.3)),
                                ),
                                child: Center(
                                  child: Text(
                                    "ACTUALIZAR CREDENCIALES",
                                    style: TextStyle(
                                      color: SpotlyColors.accent(dark),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40), // Espacio extra al final
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveButton(bool dark) {
    return SpotlyInteractive(
      onTap: () {
        if (_nameController.text.trim().isEmpty ||
            _usernameController.text.trim().isEmpty) {
          SpotlyUI.toast(context, "Nombre y usuario son requeridos");
          return;
        }
        context.read<ProfileBloc>().add(
              OnUpdateProfile(
                nombres: _nameController.text.trim(),
                apellidos: _lastNameController.text.trim(),
                nombreUsuario: _usernameController.text.trim(),
              ),
            );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [SpotlyColors.accent(dark), const Color(0xFF2DD4BF)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: SpotlyColors.accent(dark).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Center(
          child: Text("GUARDAR CAMBIOS PERFIL",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
        ),
      ),
    );
  }

  Widget _buildInput(
      String label, IconData icon, TextEditingController controller, bool dark,
      {bool enabled = true, bool obscure = false}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      style: TextStyle(
          color: enabled
              ? SpotlyColors.text(dark)
              : SpotlyColors.text(dark).withOpacity(0.5)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: SpotlyColors.text(dark).withOpacity(0.5), fontSize: 13),
        prefixIcon: Icon(icon,
            color: enabled
                ? SpotlyColors.accent(dark)
                : SpotlyColors.subText(dark),
            size: 20),
        filled: true,
        fillColor: dark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: SpotlyColors.accent(dark), width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
      ),
    );
  }
}
