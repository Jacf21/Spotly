import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/utils/theme_utils.dart';
import '../../../../core/themes/spotly_colors.dart';
import '../../../../core/widgets/layout/spotly_topbar.dart';
import '../../../../core/widgets/common/spotly_logo.dart';
import '../../../../core/widgets/common/spotly_card.dart';
import '../../../../core/widgets/interactive/spotly_interactive.dart';
import '../../../../core/utils/spotly_ui.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _camposValidos = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_validarCampos);
    _lastNameController.addListener(_validarCampos);
    _emailController.addListener(_validarCampos);
    _passwordController.addListener(_validarCampos);
    _confirmPasswordController.addListener(_validarCampos);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  /// VALIDACIÓN
  void _validarCampos() {
    setState(() {
      _camposValidos =
          _nameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  /// 🔐 REGISTER
  Future<void> _handleRegister() async {
    if (!_camposValidos) {
      SpotlyUI.toast(context, "Completa todos los campos");
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      SpotlyUI.toast(context, "Las contraseñas no coinciden");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      if (user != null) {
        /// 👤 INSERTAR PERFIL
        await Supabase.instance.client.from('perfiles').insert({
          'id_usuario': user.id,
          'email': _emailController.text.trim(),
          'nombres': _nameController.text.trim(),
          'apellidos': _lastNameController.text.trim(),
          'nombre_usuario': _emailController.text.split('@')[0],
          'rol': 'user',
        });

        if (!mounted) return;

        SpotlyUI.toast(context, "Cuenta creada correctamente 🎉");

        context.go('/login');
      }
    } on AuthException catch (e) {
      SpotlyUI.toast(context, e.message);
    } catch (e) {
      debugPrint("ERROR: $e");
      SpotlyUI.toast(context, "Error al registrar");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() => context.go('/login');

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: SpotlyColors.bg(dark),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                /// 🔝 TOP BAR
                SpotlyTopBar(
                  dark: dark,
                  isAdmin: false,
                  onTheme: () => ThemeUtils.toggle(context),
                  onSearch: () {},
                ),

                const SizedBox(height: 30),

                /// CARD
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SpotlyCrystalCard(
                        dark: dark,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              SpotlyLogo(dark: dark, size: 32)
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .scale(delay: 200.ms),

                              const SizedBox(height: 10),

                              Text(
                                "Crear cuenta",
                                style: TextStyle(
                                  color: SpotlyColors.text(dark),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 30),

                              _buildInput("Nombres", LucideIcons.user, _nameController, dark),
                              const SizedBox(height: 15),

                              _buildInput("Apellidos", LucideIcons.userCheck, _lastNameController, dark),
                              const SizedBox(height: 15),

                              _buildInput("Correo electrónico", LucideIcons.mail, _emailController, dark),
                              const SizedBox(height: 15),

                              _buildInput("Contraseña", LucideIcons.lock, _passwordController, dark, obscure: true),
                              const SizedBox(height: 15),

                              _buildInput("Confirmar contraseña", LucideIcons.shieldCheck, _confirmPasswordController, dark, obscure: true),

                              const SizedBox(height: 30),

                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : _buildRegisterButton(dark),

                              const SizedBox(height: 15),

                              TextButton(
                                onPressed: _goBack,
                                child: Text(
                                  "¿Ya tienes cuenta? Iniciar sesión",
                                  style: TextStyle(
                                    color: SpotlyColors.subText(dark),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(bool dark) {
    return SpotlyInteractive(
      onTap: _handleRegister,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              SpotlyColors.accent(dark),
              const Color(0xFF2DD4BF),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: SpotlyColors.shadow(dark),
        ),
        child: const Center(
          child: Text(
            "CREAR CUENTA",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    IconData icon,
    TextEditingController controller,
    bool dark, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: SpotlyColors.text(dark)),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
          color: SpotlyColors.subText(dark),
        ),
        prefixIcon: Icon(
          icon,
          color: SpotlyColors.accent(dark),
        ),
        filled: true,
        fillColor: dark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}