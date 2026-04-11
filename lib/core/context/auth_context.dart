import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _role;

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;

  void login(String role) {
    _isLoggedIn = true;
    _role = role;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _role = null;
    notifyListeners();
  }
}