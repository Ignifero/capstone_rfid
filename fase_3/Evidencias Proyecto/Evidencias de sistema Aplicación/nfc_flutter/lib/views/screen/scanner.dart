import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_flutter/viewmodels/scanner_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scannerViewModel = Provider.of<ScannerViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Escanea la etiqueta Nfc'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (scannerViewModel.isScanning)
              CircularProgressIndicator()
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // Obtener el usuarioId desde Firebase Authentication
                      final usuarioId = FirebaseAuth.instance.currentUser?.uid;

                      if (usuarioId != null) {
                        // Llamar a la función de escaneo pasando el usuarioId
                        scannerViewModel.scanNfcAndCheckProduct(
                            context, usuarioId);
                      } else {
                        // Si no hay usuario autenticado, mostrar un mensaje
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Por favor, inicia sesión para escanear el producto.')),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.nfc, // Ícono NFC
                      size: 80.0, // Tamaño más grande para mejor visibilidad
                      color: Colors.blue, // Color del ícono
                    ),
                  ),
                  const Text(
                    'Escanear', // Texto debajo del ícono
                    style: TextStyle(
                      fontSize: 16.0, // Tamaño del texto
                      fontWeight: FontWeight.bold, // Estilo del texto
                      color: Colors.blue, // Color del texto
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
