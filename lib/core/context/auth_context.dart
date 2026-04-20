import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _role;
  String? _userId; // Agregado para rastrear el UID de Supabase

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;
  String? get userId => _userId; // Getter para el ID del usuario

  // Modificado para recibir el UID al iniciar sesión
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
    notifyListeners();
  }
}
