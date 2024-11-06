import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_flutter/viewmodels/User_viewmodel/auth_viewmodel.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("REGISTRO DE USUARIO"),
        backgroundColor: const Color.fromARGB(255, 105, 64, 255),
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo_nfc.png', // Asegúrate que esta ruta es correcta
              fit: BoxFit.cover,
            ),
          ),
          // Contenido de la pantalla
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final email = _emailController.text;
                    final password = _passwordController.text;

                    // Validar longitud de la contraseña
                    if (password.isEmpty || password.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La contraseña debe tener al menos 6 caracteres.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // No continuar si la validación falla
                    }

                    // Intentar registrar
                    try {
                      await authViewModel.register(email, password);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Registro exitoso.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      // Muestra el error del AuthViewModel si ocurre
                      String message;
                      if (e is FirebaseAuthException) {
                        switch (e.code) {
                          case 'weak-password':
                            message =
                                'La contraseña debe tener al menos 6 caracteres.';
                            break;
                          case 'invalid-email':
                            message = 'El correo electrónico no es válido.';
                            break;
                          case 'email-already-in-use':
                            message = 'El correo electrónico ya está en uso.';
                            break;
                          default:
                            message = 'Error de registro: ${e.message}';
                        }
                      } else {
                        message = 'Error desconocido: $e';
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text("Registrarse"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
