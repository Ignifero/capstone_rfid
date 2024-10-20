// views/screen/scanner.dart
import 'package:flutter/material.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear')),
      body: Center(
        child: const Text('Aquí puedes escanear los códigos.'),
      ),
    );
  }
}
