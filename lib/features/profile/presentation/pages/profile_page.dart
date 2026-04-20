import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

// --- IMPORTS DE CORE ---
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/widgets/common/spotly_card.dart';
import 'package:spotly/core/widgets/interactive/spotly_interactive.dart';
import 'package:spotly/core/utils/spotly_ui.dart';
import 'package:spotly/core/utils/theme_utils.dart';

// --- IMPORT DEL BLOC ---
import 'package:spotly/features/profile/presentation/bloc/profile_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controladores Perfil
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedGender;

  // Controladores Seguridad (Password)
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
    _bioController.dispose();
    _birthDateController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _currentPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  // --- LÓGICA DE CAMBIO DE CONTRASEÑA ---
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
      SpotlyUI.toast(context, "La nueva contraseña no coincide");
      return;
    }

    setState(() => _isUpdatingPass = true);
    try {
      final email = Supabase.instance.client.auth.currentUser?.email;
      if (email == null) return;

      // Re-autenticar para validar contraseña antigua
      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: current);
      // Actualizar a la nueva
      await Supabase.instance.client.auth
          .updateUser(UserAttributes(password: next));

      SpotlyUI.toast(context, "✨ Contraseña actualizada");
      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();
    } catch (e) {
      SpotlyUI.toast(
          context, "Error de seguridad: Contraseña actual incorrecta");
    } finally {
      if (mounted) setState(() => _isUpdatingPass = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess)
          SpotlyUI.toast(context, "✨ Perfil actualizado");
        if (state is ProfileError) SpotlyUI.toast(context, state.message);
        if (state is ProfileLoaded) {
          final p = state.profile;
          _nameController.text = p.nombres;
          _lastNameController.text = p.apellidos;
          _usernameController.text = p.username;
          _bioController.text = p.bio ?? '';
          _birthDateController.text = p.fechaNacimiento ?? '';
          _countryController.text = p.pais ?? '';
          _cityController.text = p.ciudad ?? '';
          _selectedGender = p.genero;
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
              _buildSectionTitle(dark, "MI IDENTIDAD SPOTLY"),
              SpotlyCrystalCard(
                dark: dark,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor:
                            SpotlyColors.accent(dark).withOpacity(0.1),
                        child: Icon(LucideIcons.user,
                            size: 40, color: SpotlyColors.accent(dark)),
                      ).animate().scale(duration: 400.ms),
                      const SizedBox(height: 25),
                      _buildInput(
                          "Nombres", LucideIcons.user, _nameController, dark),
                      const SizedBox(height: 15),
                      _buildInput("Apellidos", LucideIcons.userCheck,
                          _lastNameController, dark),
                      const SizedBox(height: 15),
                      _buildInput("Nombre de Usuario", LucideIcons.atSign,
                          _usernameController, dark),
                      const SizedBox(height: 15),
                      _buildInput("Biografía", LucideIcons.fileEdit,
                          _bioController, dark,
                          maxLines: 3),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle(dark, "DETALLES ADICIONALES"),
              SpotlyCrystalCard(
                dark: dark,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        dropdownColor:
                            dark ? const Color(0xFF1E293B) : Colors.white,
                        style: TextStyle(color: SpotlyColors.text(dark)),
                        decoration:
                            _inputDecoration("Género", LucideIcons.users, dark),
                        items: [
                          'Masculino',
                          'Femenino',
                          'Otro',
                          'Prefiero no decir'
                        ]
                            .map((g) =>
                                DropdownMenuItem(value: g, child: Text(g)))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedGender = val),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: _buildInput("Fecha de Nacimiento",
                              LucideIcons.calendar, _birthDateController, dark),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildInput(
                          "País", LucideIcons.globe, _countryController, dark),
                      const SizedBox(height: 15),
                      _buildInput(
                          "Ciudad", LucideIcons.mapPin, _cityController, dark),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _buildSectionTitle(dark, "SEGURIDAD"),
              SpotlyCrystalCard(
                dark: dark,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      _buildInput("Contraseña Actual", LucideIcons.key,
                          _currentPassController, dark,
                          obscure: true),
                      const SizedBox(height: 15),
                      _buildInput("Nueva Contraseña", LucideIcons.lock,
                          _newPassController, dark,
                          obscure: true),
                      const SizedBox(height: 15),
                      _buildInput("Confirmar Nueva", LucideIcons.shieldCheck,
                          _confirmPassController, dark,
                          obscure: true),
                      const SizedBox(height: 20),
                      _isUpdatingPass
                          ? const CircularProgressIndicator()
                          : _buildSecondaryButton(dark, "ACTUALIZAR CONTRASEÑA",
                              _handleUpdatePassword),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _buildSaveButton(dark),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(bool dark, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(title,
          style: TextStyle(
              color: SpotlyColors.text(dark).withOpacity(0.6),
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.1)),
    );
  }

  Widget _buildSecondaryButton(bool dark, String label, VoidCallback onTap) {
    return SpotlyInteractive(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: SpotlyColors.accent(dark)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                color: SpotlyColors.accent(dark),
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }

  Widget _buildSaveButton(bool dark) {
    return SpotlyInteractive(
      onTap: () {
        context.read<ProfileBloc>().add(OnUpdateProfile(
              nombres: _nameController.text.trim(),
              apellidos: _lastNameController.text.trim(),
              nombreUsuario: _usernameController.text.trim(),
              biografia: _bioController.text.trim(),
              genero: _selectedGender,
              fechaNacimiento: _birthDateController.text,
              pais: _countryController.text,
              ciudad: _cityController.text,
            ));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [SpotlyColors.accent(dark), const Color(0xFF2DD4BF)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
            child: Text("GUARDAR CAMBIOS TOTALES",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, bool dark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: SpotlyColors.text(dark).withOpacity(0.5)),
      prefixIcon: Icon(icon, color: SpotlyColors.accent(dark), size: 20),
      filled: true,
      fillColor: dark
          ? Colors.white.withOpacity(0.05)
          : Colors.black.withOpacity(0.03),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }

  Widget _buildInput(
      String label, IconData icon, TextEditingController controller, bool dark,
      {bool enabled = true, bool obscure = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      maxLines: maxLines,
      style: TextStyle(
          color: SpotlyColors.text(dark)), // CORRECCIÓN DE COLOR DE LETRA
      decoration: _inputDecoration(label, icon, dark),
    );
  }
}
