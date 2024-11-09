import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_flutter/viewmodels/inventario_viewmodel.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear NFC')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    _isScanning ? Colors.green : Colors.blue),
              ),
              onPressed: () async {
                await _scanNFC(context);
              },
              child: _isScanning
                  ? const Text('Escaneando NFC...')
                  : const Text('Escanear NFC'),
            ),
          ],
        ),
      ),
    );
  }

  // Función para manejar el escaneo NFC
  Future<void> _scanNFC(BuildContext context) async {
    setState(() {
      _isScanning = true;
    });

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
      setState(() {
        _isScanning = false;
      });
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
      Navigator.of(context).pop(); // Cerrar el diálogo de carga

      if (tag != null && tag.id.isNotEmpty) {
        final inventarioViewModel =
            Provider.of<InventarioViewModel>(context, listen: false);
        bool exists = await inventarioViewModel.checkIfProductExists(tag.id);

        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('La etiqueta ya está registrada en el inventario.')));
        } else {
          final product = await _showAddProductDialog(context, tag.id);
          if (product != null) {
            await inventarioViewModel.addProduct(product);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Producto agregado exitosamente')));
          }
        }
      } else {
        print("No se encontró etiqueta NFC.");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('No se pudo leer la etiqueta NFC. Intente nuevamente.')));
      }
    } catch (e) {
      print('Error leyendo NFC: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al leer la etiqueta NFC. Intente nuevamente.')));
    } finally {
      await FlutterNfcKit.finish();
      setState(() {
        _isScanning = false; // Revertir el estado después de intentar escanear
      });
    }
  }

  // Mostrar un cuadro de diálogo para ingresar los datos del producto
  Future<ProductModel?> _showAddProductDialog(
      BuildContext context, String tagId) {
    TextEditingController nombreController = TextEditingController();
    TextEditingController cantidadController = TextEditingController();
    TextEditingController ubicacionController = TextEditingController();

    return showDialog<ProductModel>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Agregar Producto"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: cantidadController,
                decoration: InputDecoration(labelText: "Cantidad"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ubicacionController,
                decoration: InputDecoration(labelText: "Ubicación"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar diálogo sin agregar
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                // Validar la cantidad antes de agregar el producto
                if (nombreController.text.isEmpty ||
                    cantidadController.text.isEmpty ||
                    ubicacionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Todos los campos son obligatorios.')));
                  return;
                }

                final product = ProductModel(
                  etiquetaId: tagId, // Usar el ID del tag NFC
                  nombre: nombreController.text,
                  cantidad: int.tryParse(cantidadController.text) ?? 1,
                  ubicacion: ubicacionController.text,
                );
                Navigator.of(context).pop(product);
              },
              child: Text("Agregar"),
            ),
          ],
        );
      },
    );
  }
}
