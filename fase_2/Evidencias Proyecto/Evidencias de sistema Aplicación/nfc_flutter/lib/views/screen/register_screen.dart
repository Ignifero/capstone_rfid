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
        backgroundColor: const Color.fromARGB(
            255, 105, 64, 255), // Azul intenso para la AppBar
      ),
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/logo_nfc.png', // Ruta de tu imagen
              fit: BoxFit.cover, // Ajustar la imagen al tamaño del contenedor
            ),
          ),
          // Contenido de la pantalla
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centrar contenido verticalmente
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16), // Espacio entre campos
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  obscureText: true, // Ocultar texto de contraseña
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700], // Color del botón
                    foregroundColor: Colors.white, // Color del texto
                  ),
                  onPressed: () {
                    authViewModel.register(
                      _emailController.text,
                      _passwordController.text,
                    );
                    Navigator.pushReplacementNamed(context, '/login');
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
