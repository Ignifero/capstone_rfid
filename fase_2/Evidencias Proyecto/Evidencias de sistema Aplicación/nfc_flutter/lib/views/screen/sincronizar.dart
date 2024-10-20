// views/screen/sincronizar.dart
import 'package:flutter/material.dart';

class SincronizarScreen extends StatelessWidget {
  const SincronizarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronizar')),
      body: Center(
        child: const Text('Aquí puedes sincronizar los datos.'),
      ),
    );
  }
}
