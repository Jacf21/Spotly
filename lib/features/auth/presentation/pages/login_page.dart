import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'spotly_ui.dart';

// 👇 IMPORTANTE: importar el layout guest
import 'guest_home_content.dart';

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

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      SpotlyUI.toast(context, "Por favor, llena todos los campos", _isDarkMode);
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

        if (userRol.trim().toLowerCase() == 'admin') {
          SpotlyUI.toast(context, "Modo Admin: Acceso Total", _isDarkMode);

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/admin',
            (route) => false,
          );
        } else {
          SpotlyUI.toast(context, "¡Bienvenido a Spotly!", _isDarkMode);

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/user',
            (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      SpotlyUI.toast(context, "Credenciales incorrectas", _isDarkMode);
      debugPrint("Auth Error: ${e.message}");
    } catch (e) {
      debugPrint("Error crítico en consulta de perfil: $e");

      SpotlyUI.toast(context, "Error al verificar permisos", _isDarkMode);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/user',
          (route) => false,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goGuest() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/guest',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GuestHomeContent(
      isDarkMode: _isDarkMode,
      selectedIndex: -1, // 👈 ninguno activo
      onToggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),

      // 👇 si tocan navbar, los mandas a guest real
      onNavItemTapped: (index) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/guest',
          (route) => false,
        );
      },

      onGuestAction: (action) {
        SpotlyUI.toast(context, "Inicia sesión para $action", _isDarkMode);
      },

      // 👇 ESTE ES TU LOGIN COMO CONTENIDO CENTRAL
      child: Center(
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
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _emailController,
                  label: "Correo electrónico",
                  icon: LucideIcons.mail,
                  isDark: _isDarkMode,
                ).animate().slideX(begin: -0.1),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: "Contraseña",
                  icon: LucideIcons.lock,
                  isDark: _isDarkMode,
                  isPassword: true,
                ).animate().slideX(begin: 0.1),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(
                        color: Color(0xFF2DD4BF),
                      )
                    : SpotlyInteractive(
                        onTap: _handleLogin,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                SpotlyColors.accent(_isDarkMode),
                                const Color(0xFF2DD4BF).withBlue(200),
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
                      ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _goGuest,
                  child: Text(
                    "CONTINUAR COMO INVITADO",
                    style: TextStyle(
                      color: SpotlyColors.accent(_isDarkMode),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: SpotlyColors.subText(isDark),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: SpotlyColors.accent(isDark),
          size: 20,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: SpotlyColors.accent(isDark),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
