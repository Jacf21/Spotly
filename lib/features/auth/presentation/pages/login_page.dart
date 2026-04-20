import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/context/auth_context.dart';
import '../../../../core/utils/theme_utils.dart';
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

  void _toggleTheme() {
    ThemeUtils.toggle(context);
  }

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
        final user = response.user!;
        final auth = Provider.of<AuthProvider>(context, listen: false);

        // 🔍 Buscar perfil
        final perfil = await Supabase.instance.client
            .from('perfiles')
            .select()
            .eq('id_usuario', user.id)
            .maybeSingle();

        // 🆕 Si no existe → crearlo
        if (perfil == null) {
          await Supabase.instance.client.from('perfiles').insert({
            'id_usuario': user.id,
            'nombres': 'Usuario',
            'apellidos': '',
            'rol': 'user',
          });
        }

        // 🔄 Obtener rol
        final userData = await Supabase.instance.client
            .from('perfiles')
            .select('rol')
            .eq('id_usuario', user.id)
            .single();

        final String userRol = (userData['rol'] ?? 'user').toString();

        /// ✅ GUARDAR SESIÓN GLOBAL (Ahora pasando el ID del usuario)
        auth.login(userRol, user.id);

        if (!mounted) return;

        if (userRol.toLowerCase() == 'admin') {
          SpotlyUI.toast(context, "Modo Admin: Acceso Total");
          context.go('/admin');
        } else {
          SpotlyUI.toast(context, "¡Bienvenido a Spotly!");
          context.go('/feed');
        }
      }
    } on AuthException catch (e) {
      debugPrint("Auth Error: ${e.message}");
      SpotlyUI.toast(context, e.message);
    } catch (e) {
      debugPrint("Error crítico: $e");
      SpotlyUI.toast(context, "Error al verificar permisos");

      if (mounted) {
        context.go('/feed');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 👀 CONTINUAR COMO INVITADO
  void _goGuest() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.logout();
    context.go('/feed');
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Scaffold(
      backgroundColor: SpotlyColors.bg(dark),
      body: SafeArea(
        child: Column(
          children: [
            /// 🔝 TOP BAR
            SpotlyTopBar(
              dark: dark,
              isAdmin: false,
              onTheme: _toggleTheme,
              onSearch: () {},
            ),

            /// 📦 CONTENIDO
            Expanded(child: _buildLoginContent(dark)),
          ],
        ),
      ),
    );
  }

  /// 🔗 IR A REGISTRO
  Widget _buildGoToRegisterButton(bool dark) {
    return SpotlyInteractive(
      onTap: () => context.go('/register'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: SpotlyColors.accent(dark),
          ),
        ),
        child: Center(
          child: Text(
            "CREAR CUENTA NUEVA",
            style: TextStyle(
              color: SpotlyColors.accent(dark),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 CONTENIDO CENTRAL
  Widget _buildLoginContent(bool dark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SpotlyCrystalCard(
          dark: dark,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpotlyLogo(dark: dark, size: 36)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(delay: 200.ms),
              const SizedBox(height: 10),
              Text(
                "Gestión de Turismo Bolivia",
                style: TextStyle(
                  color: SpotlyColors.subText(dark),
                  fontSize: 14,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),
              _buildTextField(
                controller: _emailController,
                label: "Correo electrónico",
                icon: LucideIcons.mail,
                isDark: dark,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                label: "Contraseña",
                icon: LucideIcons.lock,
                isDark: dark,
                isPassword: true,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : _buildLoginButton(dark),
              const SizedBox(height: 10),
              _buildGoToRegisterButton(dark),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _goGuest,
                child: Text(
                  "CONTINUAR COMO INVITADO",
                  style: TextStyle(
                    color: SpotlyColors.accent(dark),
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
  Widget _buildLoginButton(bool dark) {
    return SpotlyInteractive(
      onTap: _handleLogin,
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
