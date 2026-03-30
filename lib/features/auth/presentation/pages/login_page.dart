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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isDarkMode = true;

  /// 🔐 LOGIN REAL CON SUPABASE
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      SpotlyUI.toast(context, "Por favor, llena todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        final userData = await Supabase.instance.client
            .from('perfiles')
            .select('rol')
            .eq('id_usuario', response.user!.id)
            .single();

        final String userRol = (userData['rol'] ?? 'user').toString();

        if (!mounted) return;

        if (userRol.toLowerCase() == 'admin') {
          SpotlyUI.toast(context, "Modo Admin: Acceso Total");
          context.go('/admin');
        } else {
          SpotlyUI.toast(context, "¡Bienvenido a Spotly!");
          context.go('/user');
        }
      }
    } on AuthException catch (e) {
      SpotlyUI.toast(context, "Credenciales incorrectas");
      debugPrint("Auth Error: ${e.message}");
    } catch (e) {
      debugPrint("Error crítico: $e");

      SpotlyUI.toast(context, "Error al verificar permisos");

      if (mounted) {
        context.go('/user');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 👀 CONTINUAR COMO INVITADO
  void _goGuest() {
    context.go('/guest/home');
  }

  void _toggleTheme() => setState(() => _isDarkMode = !_isDarkMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpotlyColors.bg(_isDarkMode),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔝 TOP BAR
            SpotlyTopBar(
              dark: _isDarkMode,
              isAdmin: false,
              onTheme: _toggleTheme,
              onSearch: () {},
            ),

            /// 📦 CONTENIDO
            Expanded(child: _buildLoginContent()),
          ],
        ),
      ),
    );
  }

  /// 🎯 CONTENIDO CENTRAL
  Widget _buildLoginContent() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SpotlyCrystalCard(
          dark: _isDarkMode,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SpotlyLogo(dark: true, size: 36)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(delay: 200.ms),

              const SizedBox(height: 10),

              Text(
                "Gestión de Turismo Bolivia",
                style: TextStyle(
                  color: SpotlyColors.subText(_isDarkMode),
                  fontSize: 14,
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 40),

              _buildTextField(
                controller: _emailController,
                label: "Correo electrónico",
                icon: LucideIcons.mail,
                isDark: _isDarkMode,
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: _passwordController,
                label: "Contraseña",
                icon: LucideIcons.lock,
                isDark: _isDarkMode,
                isPassword: true,
              ),

              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator(
                      color: Color(0xFF2DD4BF),
                    )
                  : _buildLoginButton(),

              const SizedBox(height: 16),

              TextButton(
                onPressed: _goGuest,
                child: Text(
                  "CONTINUAR COMO INVITADO",
                  style: TextStyle(
                    color: SpotlyColors.accent(_isDarkMode),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔘 BOTÓN LOGIN
  Widget _buildLoginButton() {
    return SpotlyInteractive(
      onTap: _handleLogin,
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
            "INGRESAR AL SISTEMA",
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

  /// 🧩 INPUTS
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(
        color: SpotlyColors.text(isDark),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: SpotlyColors.subText(isDark),
        ),
        prefixIcon: Icon(
          icon,
          color: SpotlyColors.accent(isDark),
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}