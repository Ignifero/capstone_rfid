import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_flutter/viewmodels/User_viewmodel/auth_viewmodel.dart';

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acceder al AuthViewModel para observar el estado de autenticación
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NFC IGNITE'),
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
          // Contenido de la pantalla (sin el mensaje de bienvenida)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Aquí puedes agregar cualquier contenido adicional si lo deseas
              ],
            ),
          ),
        ],
      ),
      // Footer con los íconos
      bottomNavigationBar: BottomAppBar(
        color: Colors.white, // Fondo blanco para el footer
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Ícono de Login
              IconButton(
                iconSize: 50.0,
                color:
                    const Color.fromARGB(255, 105, 64, 255), // Color del ícono
                icon: const Icon(Icons.login),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                tooltip: 'Iniciar Sesión',
              ),
              // Ícono de Registro
              IconButton(
                iconSize: 50.0,
                color:
                    const Color.fromARGB(255, 105, 64, 255), // Color del ícono
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                tooltip: 'Registrarse',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
