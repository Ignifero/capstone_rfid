// business_logic/view_model/auth_view_model.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nfc_flutter/business_logic/actions/User_actions/auth_actions.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthUseCase _authUseCase;

  User? _user;
  User? get user => _user;

  AuthViewModel(this._authUseCase) {
    _authUseCase.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await _authUseCase.signOut();
    _user = null;
    notifyListeners();
  }

  Future<User?> login(String email, String password) async {
    try {
      _user = await _authUseCase.login(email, password);

      // Si el login falla, _user será null
      if (_user == null) {
        throw Exception("Credenciales incorrectas");
      }

      notifyListeners();
      return _user; // Devolver el usuario para manejarlo en la pantalla
    } catch (e) {
      throw e; // Volver a lanzar la excepción para manejarla en la pantalla
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      _user = await _authUseCase.register(email, password);
      notifyListeners();
      return _user; // Devolver el usuario para manejarlo en la pantalla
    } catch (e) {
      throw e; // Volver a lanzar la excepción para manejarla en la pantalla
    }
  }
}
