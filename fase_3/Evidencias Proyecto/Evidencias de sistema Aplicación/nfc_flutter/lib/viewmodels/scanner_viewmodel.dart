import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScannerViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isScanning = false;

  ScannerViewModel(param0);

  // Método para verificar si el producto existe en el inventario con el usuarioId
  Future<Map<String, dynamic>?> checkIfProductExistsInInventory(
      String etiquetaId, String usuarioId) async {
    try {
      final inventoryRef = _firestore.collection('inventarios');
      final querySnapshot = await inventoryRef.get();

      for (var doc in querySnapshot.docs) {
        final productosRef = doc.reference.collection('productos');

        final productoSnapshot = await productosRef
            .where('etiquetaId', isEqualTo: etiquetaId.trim())
            .where('usuarioId', isEqualTo: usuarioId)
            .get();

        if (productoSnapshot.docs.isNotEmpty) {
          final productData = productoSnapshot.docs.first.data();
          productData['inventarioId'] =
              doc.id; // Agregar referencia del inventario
          return productData;
        }
      }

      return null; // No encontrado en ninguna subcolección
    } catch (e) {
      print('Error al verificar el producto: $e');
      return null;
    }
  }

  // Método de escaneo y validación en Firestore
  Future<void> scanNfcAndCheckProduct(
      BuildContext context, String usuarioId) async {
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

      // Llamamos al método de Firestore para verificar si el producto existe en el inventario
      final exists =
          await checkIfProductExistsInInventory(etiquetaId, usuarioId);
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
