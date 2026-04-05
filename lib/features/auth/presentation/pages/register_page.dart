import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
  bool _isDarkMode = true;
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
    super.dispose();
  }

  /// ✅ VALIDACIÓN
  void _validarCampos() {
    setState(() {
      _camposValidos = _nameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty;
    });
  }

  /// 🔐 REGISTRO (MISMA LÓGICA QUE LOGIN)
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

      if (response.user != null) {
        await Supabase.instance.client.from('perfiles').insert({
          'id_usuario': response.user!.id,
          'nombre': _nameController.text.trim(),
          'apellidos': _lastNameController.text.trim(),
          'rol': 'user',
        });

        if (!mounted) return;

        SpotlyUI.toast(
          context,
          "Revisa tu correo para confirmar tu cuenta 📩",
        );

        context.go('/');
      }
    } on AuthException catch (e) {
      SpotlyUI.toast(context, e.message);
    } catch (e) {
      SpotlyUI.toast(context, "Error al registrar usuario");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  void _goBack() => context.go('/');

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: SpotlyColors.bg(_isDarkMode),
    body: SafeArea(
      child: Column(
        children: [

          /// TOP BAR 
          SpotlyTopBar(
            dark: _isDarkMode,
            isAdmin: false,
            onTheme: _toggleTheme,
            onSearch: () {},
          ),

          const Spacer(),

          /// 💳 CARD ANIMADA
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SpotlyCrystalCard(
                dark: _isDarkMode,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    const SpotlyLogo(dark: true, size: 32)
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .scale(delay: 200.ms),

                    const SizedBox(height: 10),

                    Text(
                      "Crear cuenta",
                      style: TextStyle(
                        color: SpotlyColors.text(_isDarkMode),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 30),

                    _buildInput(
                      "Nombres",
                      LucideIcons.user,
                      _nameController,
                    ),

                    const SizedBox(height: 15),

                    _buildInput(
                      "Apellidos",
                      LucideIcons.userCheck,
                      _lastNameController,
                    ),

                    const SizedBox(height: 15),

                    _buildInput(
                      "Correo electrónico",
                      LucideIcons.mail,
                      _emailController,
                    ),

                    const SizedBox(height: 15),

                    _buildInput(
                      "Contraseña",
                      LucideIcons.lock,
                      _passwordController,
                      obscure: true,
                    ),

                    const SizedBox(height: 15),

                    _buildInput(
                      "Confirmar contraseña",
                      LucideIcons.shieldCheck,
                      _confirmPasswordController,
                      obscure: true,
                    ),

                    const SizedBox(height: 30),

                    /// 🔘 BOTÓN CON SPOTLY INTERACTIVE
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SpotlyInteractive(
                            onTap: () {
                             if (_camposValidos && !_isLoading) {
                                      _handleRegister();
                            } else {
                               SpotlyUI.toast(context, "Completa todos los campos");
                                   }
                                    },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    SpotlyColors.accent(_isDarkMode),
                                    const Color(0xFF2DD4BF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: SpotlyColors.shadow(_isDarkMode),
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
                          ),

                    const SizedBox(height: 15),

                    TextButton(
                      onPressed: _goBack,
                      child: Text(
                        "¿Ya tienes cuenta? Iniciar sesión",
                        style: TextStyle(
                          color: SpotlyColors.subText(_isDarkMode),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    ),
  );
   }


  /// INPUT 
  Widget _buildInput(
  String label,
  IconData icon,
  TextEditingController controller, {
  bool obscure = false,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    style: TextStyle(color: SpotlyColors.text(_isDarkMode)),
    decoration: InputDecoration(
      hintText: label,
      hintStyle: TextStyle(
        color: SpotlyColors.subText(_isDarkMode),
      ),
      prefixIcon: Icon(
        icon,
        color: SpotlyColors.accent(_isDarkMode),
      ),
      filled: true,
      fillColor: _isDarkMode
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