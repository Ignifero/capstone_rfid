import 'package:flutter/material.dart';
import 'package:nfc_flutter/business_logic/service/firestore_service.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_flutter/business_logic/models/inventario.dart';

class InventarioViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String selectedInventarioId = 'inventarios';
  List<String> selectedTableNames = [];
  String? selectedTableName;
  bool isScanning = false;
  String scannedData = '';
  bool isLoading = false;
  List<Inventario> inventarios = []; // Lista que almacena los inventarios
  List<Map<String, dynamic>> scannedProducts = [];
  List<Map<String, dynamic>> matchedProducts = [];
  bool isTestingMode = true;

  get productos => null; // Definir si estamos en modo de prueba

  // Método para verificar si un producto ya existe en el inventario específico del usuario
  Future<bool> checkIfProductExistsInSpecificInventario(
      String etiquetaId) async {
    return await _firestoreService
        .checkIfProductExistsInSpecificInventario(etiquetaId);
  }

  // Método para obtener las tablas de inventario para el usuario autenticado
  Future<void> fetchTables() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('inventarios').get();

      if (snapshot.docs.isNotEmpty) {
        inventarios = snapshot.docs.map((doc) {
          return Inventario.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
        notifyListeners();
      } else {
        inventarios = [];
        notifyListeners();
      }
    } catch (e) {
      print("Error al obtener inventarios: $e");
      inventarios = [];
      notifyListeners();
    }
  }

  Future<void> agregarProducto(
      String inventarioId, ProductModel nuevoProducto) async {
    try {
      print('Iniciando agregarProducto...');
      print('Inventario ID: $inventarioId');
      print('Producto: ${nuevoProducto.toMap()}');

      // Obtener usuario autenticado
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Usuario no autenticado.');
        return;
      }
      print('Usuario autenticado: ${user.uid}');

      // Generar un nuevo ID de producto automáticamente
      String idProducto =
          FirebaseFirestore.instance.collection('productos').doc().id;

      // Crear datos del producto
      Map<String, dynamic> datosProducto = {
        'nombre': nuevoProducto.nombre,
        'cantidad': nuevoProducto.cantidad,
        'ubicacion': nuevoProducto.ubicacion,
        'etiquetaId': nuevoProducto.etiquetaId,
      };

      // Escribir en Firestore usando el ID generado automáticamente
      await FirebaseFirestore.instance
          .collection('inventarios')
          .doc(inventarioId)
          .collection('productos')
          .doc(idProducto)
          .set(datosProducto);

      print('Producto agregado correctamente con ID: $idProducto');

      // Actualizar productos después de agregar
      await fetchProductosOnce(
          inventarioId); // Llama al método que actualiza la lista
    } catch (e) {
      print('Error al agregar el producto: $e');
    }
  }

  // Método para crear una nueva tabla de inventario
  Future<void> createNewTable(String inventarioId, String tableName) async {
    try {
      // Verificar que el usuario esté autenticado
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('Error: El usuario no está autenticado');
        return;
      }

      // Limpiar el nombre de la tabla para asegurarse de que sea un identificador válido
      String sanitizedTableName =
          tableName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');

      // Crear documento con el nombre de la tabla dentro de la colección 'inventarios'
      await FirebaseFirestore.instance
          .collection('inventarios') // Colección principal
          .doc(
              sanitizedTableName) // El nombre de la tabla como documento (limpio)
          .set({
        'nombre': tableName,
        'fecha_creacion':
            FieldValue.serverTimestamp(), // Asegurarse de que no sea nulo
      });

      // Después de crear la tabla, recargar la lista de inventarios
      await fetchTables();
    } catch (e) {
      print('Error al crear la tabla: $e');
    }
  }

  int productosTotales = 0; // Propiedad para contar los productos

  Future<List<ProductModel>> fetchProductosOnce(String inventarioId) async {
    print("Iniciando fetchProductosOnce...");
    print("Inventario ID: $inventarioId");

    // Obtener los productos de la colección sin filtrar por usuarioId
    final querySnapshot = await FirebaseFirestore.instance
        .collection('inventarios')
        .doc(inventarioId)
        .collection('productos')
        .get();

    // Actualizamos el valor de productosTotales
    productosTotales = querySnapshot.docs.length;

    print(
        "Datos recibidos de Firestore: ${querySnapshot.docs.length} documentos");

    return querySnapshot.docs.map((doc) {
      return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Método para seleccionar una tabla de inventario
  void selectTable(String tableName) {
    selectedTableName =
        tableName; // Actualiza el nombre de la tabla seleccionada
    notifyListeners(); // Notificar a los oyentes para actualizar la UI
  }

// Agregar producto a la lista en tiempo real
  // Simulación de la adición del producto a la lista en tiempo real
  void addProductToRealTimeList(Map<String, dynamic> productData) {
    print(
        'Simulando adición del producto a la lista: ${productData['nombre']}');
    // Aquí puedes agregarlo a una lista en memoria o hacer alguna operación
  }

  Future<ProductModel?> scanAndCompareProduct(
      String tableName, BuildContext context) async {
    try {
      print('--- Iniciando proceso de escaneo NFC ---');
      isScanning = true;
      notifyListeners();

      // Escaneo real de la etiqueta NFC
      final nfcTag = await FlutterNfcKit.poll();
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
        return null;
      }

      final etiquetaId = nfcTag.id;
      print('Etiqueta NFC escaneada con éxito. ID: $etiquetaId');

      // Consultar productos existentes usando `fetchProductosOnce`
      final productos = await fetchProductosOnce(tableName); // Obtén la lista
      print('Productos cargados: ${productos.length}');

      // Verificar si el producto escaneado ya existe en la lista
      final existingProduct = productos.firstWhere(
        (product) => product.etiquetaId == etiquetaId,
        orElse: () => ProductModel(
            etiquetaId: "",
            nombre: "",
            cantidad: 0,
            ubicacion: ""), // Producto vacío
      );

      if (existingProduct.etiquetaId.isNotEmpty) {
        print('Producto encontrado: ${existingProduct.nombre}');
        return existingProduct; // Devuelve el producto si tiene un ID válido
      } else {
        // Control de notificaciones duplicadas
        ScaffoldMessenger.of(context)
            .clearSnackBars(); // Limpia cualquier SnackBar existente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PRODUCTO NO ENCONTRADO EN $tableName.'),
            backgroundColor: Colors.red,
          ),
        );
        print('Producto no encontrado en la tabla $tableName.');
        return null; // Retorna null si no se encuentra el producto
      }
    } catch (e) {
      print('ERROR DURANTE EL ESCANEO NFC: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    } finally {
      isScanning = false;
      notifyListeners();
      print('--- Finalizando sesión NFC ---');
    }
  }

  Future<void> scanNfcAndAddProduct(
      BuildContext context, String inventarioId) async {
    try {
      isScanning = true;
      notifyListeners();

      final nfcAvailability = await FlutterNfcKit.nfcAvailability;
      if (nfcAvailability != NFCAvailability.available) {
        // Control de notificaciones duplicadas
        ScaffoldMessenger.of(context)
            .clearSnackBars(); // Limpia cualquier SnackBar existente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('DISPOSITIVO NO SOPORTA NFC .'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      if (nfcTag.id.isEmpty) {
        // Control de notificaciones duplicadas
        ScaffoldMessenger.of(context)
            .clearSnackBars(); // Limpia cualquier SnackBar existente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NO SE DETECTA ETIQUETA NFC.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final etiquetaId = nfcTag.id;
      scannedData = etiquetaId;

      final exists = await _firestoreService.checkIfProductExistsInInventory(
          inventarioId, etiquetaId);

      if (exists != null) {
        // Control de notificaciones duplicadas
        ScaffoldMessenger.of(context)
            .clearSnackBars(); // Limpia cualquier SnackBar existente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PRODUCTO YA EXISTE EN EL INVENTARIO'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        print('Producto no encontrado, agregando al inventario');
        // Mostrar el cuadro de diálogo de agregar producto
        _showAddProductDialog(context, inventarioId, etiquetaId);
      }
    } catch (e) {
      // Control de notificaciones duplicadas
      ScaffoldMessenger.of(context)
          .clearSnackBars(); // Limpia cualquier SnackBar existente
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ERROR DURANTE EL ESCANEO NFC  $e.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isScanning = false;
      notifyListeners();
      await FlutterNfcKit.finish();
    }
  }

  void _showAddProductDialog(
      BuildContext context, String inventarioId, String etiquetaId) {
    final nombreController = TextEditingController();
    final cantidadController = TextEditingController();
    final ubicacionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar nuevo producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nombreController,
                decoration: InputDecoration(labelText: 'Nombre del producto')),
            TextField(
                controller: cantidadController,
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number),
            TextField(
                controller: ubicacionController,
                decoration: InputDecoration(labelText: 'Ubicación')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final nombre = nombreController.text.trim();
              final cantidad = int.tryParse(cantidadController.text) ?? 0;
              final ubicacion = ubicacionController.text.trim();

              if (nombre.isEmpty || cantidad <= 0 || ubicacion.isEmpty) {
                // Control de notificaciones duplicadas
                ScaffoldMessenger.of(context)
                    .clearSnackBars(); // Limpia cualquier SnackBar existente
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('POR FAVOR, COMPLETA TODOS LOS CAMPOS .'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final newProduct = ProductModel(
                  etiquetaId: etiquetaId,
                  nombre: nombre,
                  cantidad: cantidad,
                  ubicacion: ubicacion);

              // Llamar al método agregarProducto en el ViewModel
              await agregarProducto(inventarioId, newProduct);

              // Control de notificaciones duplicadas
              ScaffoldMessenger.of(context)
                  .clearSnackBars(); // Limpia cualquier SnackBar existente
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PRODUCTO AGREGADO CORRECTAMENTE .'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

class MockNfcTag {
  final String id; // Simulamos el ID de la etiqueta NFC

  MockNfcTag({required this.id});
}
