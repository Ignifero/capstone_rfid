import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream para cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Iniciar sesión con email y contraseña
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      // Inicia sesión
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      return userCredential.user; // Devuelve el usuario autenticado
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  /// Registrar un usuario con email y contraseña
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      // Registra al usuario
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      return userCredential.user; // Devuelve el usuario registrado
    } catch (e) {
      print('Error registering: $e');
      return null;
    }
  }

  /// Cerrar sesión del usuario actual
  Future<void> signOut() async {
    try {
      // Cierra sesión
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Obtener el usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
