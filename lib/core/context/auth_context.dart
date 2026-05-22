import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _role;
  String? _userId;

  // Para mostrar el mensaje de ban en la UI
  String? _banMessage;
  String? get banMessage => _banMessage;

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;
  String? get userId => _userId;
  bool _isBanning = false;
  bool _checking = false;
  bool _verifying = false;
  bool get isVerifying => _verifying;

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

  /// Verifica si la cuenta está baneada.
  /// Retorna null si puede entrar, o el mensaje de ban si está bloqueado.
  Future<String?> _checkBan(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('perfiles')
          .select('es_activo, ban_hasta, motivo_ban')
          .eq('id_usuario', userId)
          .single();

      final esActivo = data['es_activo'] as bool? ?? true;
      if (esActivo) return null; // sin ban

      final banHasta = data['ban_hasta'] != null
          ? DateTime.tryParse(data['ban_hasta'] as String)
          : null;

      // Ban temporal vencido → desbanear automáticamente
      if (banHasta != null && banHasta.isBefore(DateTime.now())) {
        await Supabase.instance.client
            .from('perfiles')
            .update({'es_activo': true, 'ban_hasta': null, 'motivo_ban': null})
            .eq('id_usuario', userId);
        return null; // ya está perdonado
      }

      // Cuenta realmente baneada → armar mensaje
      final motivo = data['motivo_ban'] as String?;
      if (banHasta != null) {
        return 'Tu cuenta está suspendida hasta '
            '${banHasta.day}/${banHasta.month}/${banHasta.year}.'
            '${motivo != null ? '\nMotivo: $motivo' : ''}';
      } else {
        return 'Tu cuenta ha sido baneada permanentemente.'
            '${motivo != null ? '\nMotivo: $motivo' : ''}';
      }
    } catch (e) {
      debugPrint('Error checking ban: $e');
      return null; // ante la duda, dejamos pasar
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
    } catch (e) {
      debugPrint('Error syncing Google profile: $e');
    }
  }

  void _init() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _isLoggedIn = true;
      _userId = session.user.id;
      _role = 'user';
      _fetchRoleFromDB(session.user.id).then((role) {
        _role = role;
        notifyListeners();
      });
    }

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // Ignorar si ya estamos procesando un login
        if (_checking) return;
        _checking = true;
        _verifying = true;
        notifyListeners();

        try {
          final userId = session.user.id;
          final provider = session.user.appMetadata['provider'];

          // Sync Google profile (no notifica todavía)
          if (provider == 'google') {
            await _syncGoogleProfile(session.user);
          }

          // Verificar ban ANTES de cualquier notifyListeners
          final banMsg = await _checkBan(userId);
          if (banMsg != null) {
            _isBanning = true;
            await Supabase.instance.client.auth.signOut();
            _isBanning = false;

            _isLoggedIn = false;
            _role = null;
            _userId = null;
            _banMessage = banMsg;
            notifyListeners(); // única notificación: cuenta baneada
            return;
          }

          // Login exitoso
          _isLoggedIn = true;
          _userId = userId;
          _banMessage = null;
          _verifying = false;
          notifyListeners();

          if (provider != 'google') {
            _role = await _fetchRoleFromDB(userId);
          }

          notifyListeners(); // única notificación: login ok

        } finally {
          _checking = false;
          _verifying = false;
        }

      } else if (event == AuthChangeEvent.signedOut) {
        if (_isBanning || _checking) {
          _verifying = false;
          notifyListeners();
          return;
        }

        _isLoggedIn = false;
        _role = null;
        _userId = null;
        notifyListeners();
      }
    });
  }

  /// Limpia el mensaje de ban una vez que la UI lo mostró.
  void clearBanMessage() {
    _banMessage = null;
  }

  Future<void> loginFromDB(String userId) async {
    _isLoggedIn = true;
    _userId = userId;
    _role = await _fetchRoleFromDB(userId);
    notifyListeners();
  }

  /// @deprecated Usar loginFromDB.
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
    _banMessage = null;
    Supabase.instance.client.auth.signOut();
    notifyListeners();
  }
}