import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:spotly/core/utils/imageHelper.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import 'package:spotly/core/widgets/common/spotly_card.dart';
import 'package:spotly/core/widgets/interactive/spotly_interactive.dart';
import 'package:spotly/core/utils/spotly_ui.dart';
import 'package:spotly/core/utils/theme_utils.dart';
import 'package:spotly/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:spotly/features/posts/presentation/pages/user_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    if (currentUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/login');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      appBar: AppBar(
        title: Text(
          'Mi Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: SpotlyColors.text(dark),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.pencil, color: SpotlyColors.accent(dark)),
            onPressed: () => _openEditProfile(context),
            tooltip: 'Editar perfil',
          ),
        ],
        backgroundColor: SpotlyColors.bg(dark),
        elevation: 0,
        automaticallyImplyLeading: false, // ← sin botón de atrás
      ),
      body: UserProfilePage(
        userId: currentUserId,
        showBackButton: false, // ← importante: oculta el botón de atrás interno
      ),
    );
  }

  void _openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
        fullscreenDialog: true,
      ),
    );
  }
}

// ============================================================================
// Pantalla de edición de perfil (formulario completo)
// ============================================================================
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  String? _selectedGender;

  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  bool _isUpdatingPass = false;

  XFile? _pendingAvatar;
  String? _currentAvatarUrl;

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
    if (picked != null && mounted) {
      setState(() {
        _birthDateController.text =
            "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

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

      await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: current);
      await Supabase.instance.client.auth
          .updateUser(UserAttributes(password: next));

      if (mounted) SpotlyUI.toast(context, "✨ Contraseña actualizada");
      _currentPassController.clear();
      _newPassController.clear();
      _confirmPassController.clear();
    } catch (e) {
      if (mounted)
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
        if (state is ProfileUpdateSuccess) {
          SpotlyUI.toast(context, "✨ Perfil actualizado");
          if (mounted) Navigator.pop(context);
        }
        if (state is ProfileError) SpotlyUI.toast(context, state.message);
        if (state is ProfileLoaded) {
          _currentAvatarUrl = state.profile.photoUrl;
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: SpotlyColors.bg(dark),
          appBar: AppBar(
            title: Text("Editar perfil",
                style: TextStyle(color: SpotlyColors.text(dark))),
            leading: IconButton(
              icon: Icon(Icons.close, color: SpotlyColors.text(dark)),
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: SpotlyColors.bg(dark),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              children: [
                _buildSectionTitle(dark, "MI IDENTIDAD SPOTLY"),
                SpotlyCrystalCard(
                  dark: dark,
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        _buildAvatarPicker(dark),
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
                          decoration: _inputDecoration(
                              "Género", LucideIcons.users, dark),
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
                            child: _buildInput(
                                "Fecha de Nacimiento",
                                LucideIcons.calendar,
                                _birthDateController,
                                dark),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildInput("País", LucideIcons.globe,
                            _countryController, dark),
                        const SizedBox(height: 15),
                        _buildInput("Ciudad", LucideIcons.mapPin,
                            _cityController, dark),
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
                            : _buildSecondaryButton(dark,
                                "ACTUALIZAR CONTRASEÑA", _handleUpdatePassword),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                _buildSaveButton(dark),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarPicker(bool dark) {
    return GestureDetector(
      onTap: () => _showAvatarOptions(dark),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: SpotlyColors.accent(dark).withOpacity(0.1),
            backgroundImage: _buildAvatarImage(),
            child: _buildAvatarImage() == null
                ? Icon(LucideIcons.user, size: 40, color: SpotlyColors.accent(dark))
                : null,
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: SpotlyColors.accent(dark),
              shape: BoxShape.circle,
              border: Border.all(color: SpotlyColors.bg(dark), width: 2),
            ),
            child: const Icon(LucideIcons.camera, size: 14, color: Colors.white),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms);
  }

  ImageProvider? _buildAvatarImage() {
    if (_pendingAvatar != null) {
      return kIsWeb
          ? NetworkImage(_pendingAvatar!.path)
          : FileImage(File(_pendingAvatar!.path)) as ImageProvider;
    }
    if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
      return NetworkImage(_currentAvatarUrl!);
    }
    return null;
  }

  void _showAvatarOptions(bool dark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SpotlyColors.card(dark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(LucideIcons.camera, color: SpotlyColors.accent(dark)),
              title: Text('Tomar foto', style: TextStyle(color: SpotlyColors.text(dark))),
              onTap: () async {
                Navigator.pop(context);
                final file = await ImageHelper.pickImage(ImageSource.camera);
                if (file != null && mounted) setState(() => _pendingAvatar = file);
              },
            ),
            ListTile(
              leading: Icon(LucideIcons.image, color: SpotlyColors.accent(dark)),
              title: Text('Elegir de galería', style: TextStyle(color: SpotlyColors.text(dark))),
              onTap: () async {
                Navigator.pop(context);
                final file = await ImageHelper.pickImage(ImageSource.gallery);
                if (file != null && mounted) setState(() => _pendingAvatar = file);
              },
            ),
          ],
        ),
      ),
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
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return;
        if (_pendingAvatar != null) {
          context.read<ProfileBloc>().add(
            OnUpdateAvatar(userId: userId, file: _pendingAvatar!),
          );
        }
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
            child: Text("GUARDAR CAMBIOS",
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
      style: TextStyle(color: SpotlyColors.text(dark)),
      decoration: _inputDecoration(label, icon, dark),
    );
  }
}
