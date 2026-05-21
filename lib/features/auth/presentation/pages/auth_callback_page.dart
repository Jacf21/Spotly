import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/context/auth_context.dart';

class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({super.key});

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    try {
      // Supabase con PKCE intercepta el ?code= automáticamente.
      // Esperamos brevemente a que la sesión esté lista.
      await Future.delayed(const Duration(milliseconds: 500));

      final session = Supabase.instance.client.auth.currentSession;
      if (!mounted) return;

      if (session != null) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        final user = session.user;

        // Crear perfil si no existe (primera vez con OAuth)
        final perfil = await Supabase.instance.client
            .from('perfiles')
            .select('rol')
            .eq('id_usuario', user.id)
            .maybeSingle();

        if (perfil == null) {
          await Supabase.instance.client.from('perfiles').insert({
            'id_usuario': user.id,
            'nombres': user.userMetadata?['full_name'] ?? 'Usuario',
            'apellidos': '',
            'rol': 'user',
          });
        }

        // loginFromDB lee el rol desde BD (fuente de verdad), no del JWT.
        // Esto garantiza que admin en móvil funcione igual que en web.
        await auth.loginFromDB(user.id);

        if (!mounted) return;
        context.go(auth.role == 'admin' ? '/admin' : '/feed');
      } else {
        context.go('/login');
      }
    } catch (e) {
      debugPrint('AuthCallback error: $e');
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}