import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _role;

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;

  AuthProvider() {
    _init();
  }

  void _init() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      _isLoggedIn = true;
      _role = session.user.userMetadata?['role'] as String? ?? 'user';
    }

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _isLoggedIn = true;
        _role = session.user.userMetadata?['role'] as String? ?? 'user';
      } else if (event == AuthChangeEvent.signedOut) {
        _isLoggedIn = false;
        _role = null;
      }

      notifyListeners();
    });
  }

  // ← de vuelta para compatibilidad con login_page.dart
  void login(String role) {
    _isLoggedIn = true;
    _role = role;
    notifyListeners();
  }

  void logout() {
    Supabase.instance.client.auth.signOut();
  }
}