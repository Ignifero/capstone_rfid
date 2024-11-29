// widgets/navigation_bar.dart
import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor:
          const Color.fromARGB(255, 111, 80, 252), // Azul intenso para el fondo
      selectedItemColor: Colors.white, // Color para el icono seleccionado
      unselectedItemColor: const Color.fromARGB(
          179, 216, 215, 215), // Color para los íconos no seleccionados
      type: BottomNavigationBarType
          .fixed, // Asegura que todos los íconos tengan color fijo
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Inventario',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code_scanner),
          label: 'Escanear',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sync),
          label: 'Sincronizar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Ajustes',
        ),
      ],
    );
  }
}
