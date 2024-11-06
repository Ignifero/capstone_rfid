// business_logic/use_cases/auth_use_case.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nfc_flutter/business_logic/service/authService.dart';

class AuthUseCase {
  final AuthService _authService;

  AuthUseCase(this._authService);

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<User?> login(String email, String password) async {
    try {
      return await _authService.loginWithEmail(email, password);
    } catch (e) {
      throw e; // Propaga el error para que el ViewModel pueda capturarlo y mostrar el mensaje en la vista
    }
  }

  Future<User?> register(String email, String password) async {
    try {
      return await _authService.registerWithEmail(email, password);
    } catch (e) {
      throw e; // Propaga el error
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
