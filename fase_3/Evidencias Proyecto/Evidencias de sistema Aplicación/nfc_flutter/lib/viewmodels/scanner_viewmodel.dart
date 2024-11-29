import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScannerViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isScanning = false;

  ScannerViewModel(firestoreService);

  // Método para verificar si un producto existe
  Future<Map<String, dynamic>?> checkIfProductExistsInInventory(
      String etiquetaId) async {
    try {
      final inventoryRef = _firestore.collection('inventarios');

      // Obtener todos los documentos en la colección 'inventarios'
      final querySnapshot = await inventoryRef.get();

      for (var doc in querySnapshot.docs) {
        final productosRef = doc.reference.collection('productos');

        // Buscar en la subcolección 'productos' si el etiquetaId coincide
        final productoSnapshot =
            await productosRef.where('etiquetaId', isEqualTo: etiquetaId).get();

        if (productoSnapshot.docs.isNotEmpty) {
          final productData = productoSnapshot.docs.first.data();

          return productData; // Devuelve los detalles del producto
        }
      }

      return null; // Si no se encuentra en ninguna subcolección
    } catch (e) {
      print('Error al verificar el producto: $e');
      return null;
    }
  }

/*
  // Simulación de la función poll de FlutterNfcKit
  Future<MockNfcTag> mockPoll() async {
    print('Simulando escaneo NFC...');
    await Future.delayed(
        Duration(seconds: 2)); // Simulamos el tiempo de escaneo
    return MockNfcTag(
        id: '046BA6A2A51C90'); // ID ficticio de la etiqueta que sabemos que está en el inventario
  }
*/
  // Método de escaneo y validación en Firestore
  Future<void> scanNfcAndCheckProduct(BuildContext context) async {
    try {
      print('--- Iniciando proceso de escaneo NFC ---');
      isScanning = true;
      notifyListeners();

      // Lectura real de la etiqueta NFC
      final nfcTag = await FlutterNfcKit.poll(); // Escaneo real
      print('Etiqueta detectada: ${nfcTag.id}');

      if (nfcTag.id.isEmpty) {
        // Control de notificaciones duplicadas
        ScaffoldMessenger.of(context)
            .clearSnackBars(); // Limpia cualquier SnackBar existente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NO SE DETECTÓ ETIQUETA NFC'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final etiquetaId = nfcTag.id;
      print('Etiqueta NFC escaneada con éxito. ID: $etiquetaId');

      // Llamamos al método de Firestore para verificar si el producto existe en la base de datos
      final exists = await checkIfProductExistsInInventory(etiquetaId);
      if (exists != null) {
        // Producto encontrado
        ScaffoldMessenger.of(context).clearSnackBars();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Producto Encontrado',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              content: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nombre: ${exists['nombre']}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ubicación: ${exists['ubicacion']}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cantidad: ${exists['cantidad']}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    // Añadir más campos si es necesario
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.close, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar el diálogo
                  },
                ),
              ],
            );
          },
        );
        print('Producto encontrado: ${exists['nombre']}');
      } else {
        // Producto no encontrado
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PRODUCTO NO EXISTE EN LOS INVENTARIOS'),
            backgroundColor: Colors.red,
          ),
        );
        print('Producto no encontrado');
      }
    } catch (e) {
      print('ERROR DURANTE EL ESCANEO NFC: $e');
      // Control de notificaciones duplicadas
      ScaffoldMessenger.of(context)
          .clearSnackBars(); // Limpia cualquier SnackBar existente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'ERROR DURANTE EL ESCANEO NFC, REVISA TU DISPOSITIVO Y TU COMPATIBILIDAD'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isScanning = false;
      notifyListeners();
      print('--- Finalizando sesión NFC ---');
    }
  }
}
