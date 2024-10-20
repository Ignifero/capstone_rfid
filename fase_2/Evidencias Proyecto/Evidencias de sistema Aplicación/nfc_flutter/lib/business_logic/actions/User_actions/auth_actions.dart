// business_logic/use_cases/auth_use_case.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nfc_flutter/business_logic/service/authService.dart';

class AuthUseCase {
  final AuthService _authService;

  AuthUseCase(this._authService);

  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<User?> login(String email, String password) {
    return _authService.loginWithEmail(email, password);
  }

  Future<User?> register(String email, String password) {
    return _authService.registerWithEmail(email, password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
