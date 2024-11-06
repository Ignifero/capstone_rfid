import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_flutter/viewmodels/inventario_viewmodel.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _scanNFC(context);
              },
              child: const Text('Escanear NFC'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanNFC(BuildContext context) async {
    bool hasNFC = false;

    try {
      // Intentar hacer ping al lector NFC para verificar si está disponible
      final availability = await FlutterNfcKit.poll();
      hasNFC = availability != null;
      await FlutterNfcKit.finish();
    } catch (e) {
      print(
          'Error: el dispositivo no tiene NFC disponible o el lector no responde.');
      hasNFC = false;
    }

    if (!hasNFC) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Este dispositivo no soporta NFC.')));
      return;
    }

    // Mostrar un diálogo de carga mientras se intenta la lectura NFC
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Escaneando NFC..."),
          ],
        ),
      ),
    );

    try {
      final tag = await FlutterNfcKit.poll();
      Navigator.of(context).pop();

      if (tag != null) {
        final inventarioViewModel =
            Provider.of<InventarioViewModel>(context, listen: false);
        bool exists = await inventarioViewModel.checkIfExists(tag.id);

        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('La etiqueta ya está registrada en el inventario.')));
          print('Etiqueta NFC ya registrada.');
        } else {
          _showAddProductDialog(context, tag.id);
          print('Etiqueta NFC escaneada: ${tag.id}');
        }
      } else {
        print("No se encontró etiqueta NFC.");
      }
    } catch (e) {
      print('Error leyendo NFC: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al leer la etiqueta NFC. Intente nuevamente.')));
    } finally {
      await FlutterNfcKit.finish();
    }
  }

  void _showAddProductDialog(BuildContext context, String nfcId) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController cantidadController = TextEditingController();
    final TextEditingController ubicacionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ubicacionController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                final String nombre = nombreController.text;
                final int cantidad = int.tryParse(cantidadController.text) ?? 0;
                final String ubicacion = ubicacionController.text;

                if (nombre.isNotEmpty && cantidad > 0 && ubicacion.isNotEmpty) {
                  final nuevoProducto = ProductModel(
                    id: nfcId,
                    nombre: nombre,
                    cantidad: cantidad,
                    ubicacion: ubicacion,
                  );
                  Provider.of<InventarioViewModel>(context, listen: false)
                      .addItem(nuevoProducto);
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pop(); // Volver a la pantalla de inventario
                }
              },
              child: const Text('Agregar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
