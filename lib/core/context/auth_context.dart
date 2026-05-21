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

  Future<String> _fetchRoleFromDB(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('perfiles')
          .select('rol')
          .eq('id_usuario', userId)
          .maybeSingle();
      return (data?['rol'] ?? 'user').toString();
    } catch (e) {
      debugPrint('Error fetching role from DB: $e');
      return 'user';
    }
  }

  Future<void> _syncGoogleProfile(User user) async {
    try {
      final perfil = await Supabase.instance.client
          .from('perfiles')
          .select('rol')
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
        _role = 'user';
      } else {
        _role = (perfil['rol'] ?? 'user').toString();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing Google profile: $e');
    }
  }

  void _init() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _isLoggedIn = true;
      _userId = session.user.id;
      // No leer el rol del JWT aquí todavía; lo cargamos desde BD de forma async
      _role = 'user'; // valor provisional hasta que llegue la respuesta de BD
      _fetchRoleFromDB(session.user.id).then((role) {
        _role = role;
        notifyListeners();
      });
    }

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _isLoggedIn = true;
        _userId = session.user.id;
        _role = 'user'; // provisional

        // Para Google OAuth, sincronizar perfil (crea registro si no existe)
        final provider = session.user.appMetadata['provider'];
        if (provider == 'google') {
          await _syncGoogleProfile(session.user);
        } else {
          // Para email/password, solo leemos el rol desde BD
          _role = await _fetchRoleFromDB(session.user.id);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        _isLoggedIn = false;
        _role = null;
        _userId = null;
      }

      notifyListeners();
    });
  }

  /// Mantener por compatibilidad con login_page.dart y auth_callback_page.dart.
  /// Siempre sobreescribe el rol con el valor de BD para evitar
  /// que un caller pase un rol incorrecto.
  Future<void> loginFromDB(String userId) async {
    _isLoggedIn = true;
    _userId = userId;
    _role = await _fetchRoleFromDB(userId);
    notifyListeners();
  }

  /// @deprecated Usar loginFromDB. Se conserva solo para no romper callers existentes.
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
    notifyListeners();
  }
}