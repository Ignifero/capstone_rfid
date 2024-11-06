import 'package:flutter/material.dart';
import 'package:nfc_flutter/views/screen/inventario_screen.dart';
import 'package:nfc_flutter/views/screen/scanner.dart';
import 'package:nfc_flutter/views/screen/sincronizar.dart';
import 'package:nfc_flutter/views/screen/settings_screen.dart';
import 'package:nfc_flutter/views/screen/inicio_screen.dart'; // Importar InicioScreen
import 'package:nfc_flutter/views/widgets/navigation_bar.dart'; // Importa el widget custom

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  // Pantallas para el Bottom Navigation Bar
  final List<Widget> _screens = [
    const InventarioScreen(),
    const ScannerScreen(),
    const SincronizarScreen(),
    const SettingsScreen(),
  ];

  // Etiquetas para el AppBar (los títulos de cada pantalla)
  final List<String> _titles = [
    "Inventario",
    "Escanear",
    "Sincronizar",
    "Ajustes",
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Cerrar Sesión (este botón siempre estará visible en la AppBar)
  void _logout() {
    // Aquí puedes hacer el logout desde el AuthViewModel, si lo necesitas.
    // Por ejemplo, si tienes authViewModel, puedes hacer: await authViewModel.signOut();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => InicioScreen()), // Redirigir a InicioScreen
      (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900], // Fondo azul intenso
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Colors.blue[800], // Azul intenso para la AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.power_settings_new),
            onPressed: _logout,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped, // Maneja los taps para cambiar la pantalla
      ),
    );
  }
}
