import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _role;
  String? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;
  String? get userId => _userId;

  AuthProvider() {
    _init();
  }

  Future<void> _syncGoogleProfile(User user) async {
    try {
      final perfil = await Supabase.instance.client
          .from('perfiles')
          .select()
          .eq('id_usuario', user.id)
          .maybeSingle();

      if (perfil == null) {
        final metadata = user.userMetadata ?? {};
        await Supabase.instance.client.from('perfiles').insert({
          'id_usuario': user.id,
          'nombres': metadata['full_name'] ?? metadata['name'] ?? 'Usuario',
          'apellidos': '',
          'rol': 'user',
        });
      }

      // Actualizar rol desde la BD
      final userData = await Supabase.instance.client
          .from('perfiles')
          .select('rol')
          .eq('id_usuario', user.id)
          .single();

      _role = (userData['rol'] ?? 'user').toString();
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing Google profile: $e');
    }
  }

  void _init() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _isLoggedIn = true;
      _userId = session.user.id; // ← agregar
      _role = session.user.userMetadata?['role'] as String? ?? 'user';
    }

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _isLoggedIn = true;
        _userId = session.user.id; // ← agregar
        _role = session.user.userMetadata?['role'] as String? ?? 'user';
        _syncGoogleProfile(session.user); // ← llamar sync (ver paso 2)
      } else if (event == AuthChangeEvent.signedOut) {
        _isLoggedIn = false;
        _role = null;
        _userId = null;
      }

      notifyListeners();
    });
  }

  // ← de vuelta para compatibilidad con login_page.dart
  void login(String role, String userId) {
    _isLoggedIn = true;
    _role = role;
    _userId = userId;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _role = null;
    _userId = null;
    Supabase.instance.client.auth.signOut();
    notifyListeners(); // ← faltaba esto
  }
}