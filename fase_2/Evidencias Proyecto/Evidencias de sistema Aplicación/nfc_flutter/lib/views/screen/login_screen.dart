import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_flutter/viewmodels/User_viewmodel/auth_viewmodel.dart';
import 'package:nfc_flutter/views/screen/home_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("INICIO DE SESIÓN"),
        backgroundColor: const Color.fromARGB(255, 105, 64, 255),
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo_nfc.png',
              fit: BoxFit.cover,
            ),
          ),
          // Contenedor con fondo semi-transparente para mejorar la legibilidad
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Contenido de la pantalla
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centrar contenido verticalmente
              children: [
                SizedBox(height: 40), // Espacio superior para separar del logo
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                SizedBox(height: 16), // Espacio entre campos
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  obscureText:
                      true, // Asegúrate de que el campo sea de tipo password
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    // Intentamos el login
                    try {
                      await authViewModel.login(
                        _emailController.text,
                        _passwordController.text,
                      );

                      // Si el usuario es válido, navegamos
                      if (authViewModel.user != null) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        // Mostrar mensaje de error si no hay usuario
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Error en el inicio de sesión. Verifica tus credenciales.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      // Manejo de excepciones
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text("Login"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
