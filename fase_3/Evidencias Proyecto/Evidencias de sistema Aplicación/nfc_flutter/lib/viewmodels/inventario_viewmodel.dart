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
  final usuarioId = FirebaseAuth.instance.currentUser?.uid;

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

  // Agregar producto y actualizar la lista local
  Future<bool> agregarProducto(
      String inventarioId, ProductModel nuevoProducto) async {
    try {
      print('Iniciando agregarProducto...');
      print('Inventario ID: $inventarioId');
      print('Producto: ${nuevoProducto.toMap()}');

      // Validación de usuario autenticado
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Usuario no autenticado.');
        return false; // Devolver false si no está autenticado
      }

      // Obtener el usuarioId
      String usuarioId = user.uid;

      // Verificar si los datos del producto son válidos (nombre, cantidad, ubicación)
      if (nuevoProducto.nombre.isEmpty ||
          nuevoProducto.cantidad <= 0 ||
          nuevoProducto.ubicacion.isEmpty) {
        print('Datos del producto inválidos.');
        return false; // Retorna false si los datos son inválidos
      }

      // Generar un nuevo ID de producto automáticamente
      String idProducto =
          FirebaseFirestore.instance.collection('productos').doc().id;

      // Crear datos del producto, incluyendo el usuarioId
      Map<String, dynamic> datosProducto = {
        'nombre': nuevoProducto.nombre,
        'cantidad': nuevoProducto.cantidad,
        'ubicacion': nuevoProducto.ubicacion,
        'etiquetaId': nuevoProducto.etiquetaId,
        'usuarioId': usuarioId, // Aquí agregamos el usuarioId
      };

      // Comprobar si el producto ya existe en el inventario
      bool productoExistente = await checkIfProductExistsInSpecificInventario(
          nuevoProducto.etiquetaId);
      if (productoExistente) {
        print('El producto ya existe en el inventario.');
        return false; // Evitar agregar el producto si ya existe
      }

      // Escribir en Firestore usando el ID generado automáticamente
      await FirebaseFirestore.instance
          .collection('inventarios')
          .doc(inventarioId)
          .collection('productos')
          .doc(idProducto)
          .set(datosProducto);

      print('Producto agregado correctamente con ID: $idProducto');

      // Actualizar la lista de productos local
      // Asegúrate de tener un método fetchProductosOnce que cargue todos los productos
      await fetchProductosOnce(inventarioId);

      return true; // Retorna true si se agregó correctamente
    } catch (e) {
      print('Error al agregar el producto: $e');
      return false; // Retorna false si hubo un error
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

    // Si no hay productos, retornar una lista vacía
    if (querySnapshot.docs.isEmpty) {
      return []; // No hay productos en la base de datos
    }

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
            ubicacion: "",
            usuarioId: ""), // Producto vacío
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
      print('ERROR, VERIFICA TU DISPOSITIVO Y COMPATIBILIDAD CON NFC: $e');
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

  Future<bool> scanNfcAndAddProduct(
      BuildContext context, String inventarioId) async {
    try {
      isScanning = true; // Activar el spinner
      notifyListeners();

      // Verificar disponibilidad de NFC
      final nfcAvailability = await FlutterNfcKit.nfcAvailability;
      if (nfcAvailability != NFCAvailability.available) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('DISPOSITIVO NO SOPORTA NFC.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Escanear la etiqueta NFC
      final nfcTag = await FlutterNfcKit.poll(timeout: Duration(seconds: 10));
      if (nfcTag.id.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NO SE DETECTA ETIQUETA NFC.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      final etiquetaId = nfcTag.id;
      scannedData = etiquetaId;

      // Obtener usuario autenticado
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario no autenticado.'),
            backgroundColor: Colors.red,
          ),
        );
        return false; // Si el usuario no está autenticado, retornamos false
      }

      String usuarioId = user.uid; // Obtener el usuarioId

      // Verificar si el producto ya existe en el inventario
      final exists = await _firestoreService.checkIfProductExistsInInventory(
          etiquetaId, usuarioId);
      if (exists != null) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PRODUCTO YA EXISTE EN EL INVENTARIO'),
            backgroundColor: Colors.red,
          ),
        );
        return false; // Si el producto ya existe, retornar false
      }

      // Mostrar cuadro de diálogo para capturar información del producto
      await _showAddProductDialog(context, inventarioId, etiquetaId);
      return true; // Procesado correctamente
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ERROR DURANTE EL ESCANEO NFC $e.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    } finally {
      isScanning = false; // Desactivar spinner
      notifyListeners();
      await FlutterNfcKit.finish();
    }
  }

  Future<void> _showAddProductDialog(
      BuildContext context, String inventarioId, String etiquetaId) async {
    final nombreController = TextEditingController();
    final cantidadController = TextEditingController();
    final ubicacionController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar nuevo producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre del producto'),
            ),
            TextField(
              controller: cantidadController,
              decoration: InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: ubicacionController,
              decoration: InputDecoration(labelText: 'Ubicación'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final nombre = nombreController.text.trim();
              final cantidadStr = cantidadController.text.trim();
              final ubicacion = ubicacionController.text.trim();

              // Validar campos vacíos
              if (nombre.isEmpty || ubicacion.isEmpty) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Por favor, completa todos los campos.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Validar cantidad como número
              int? cantidad;
              try {
                cantidad = int.parse(cantidadStr);
                if (cantidad <= 0) throw FormatException();
              } catch (_) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cantidad debe ser un número mayor a 0.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Obtener usuarioId de FirebaseAuth
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Usuario no autenticado.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              final usuarioId = user.uid;

              // Crear modelo de producto
              final nuevoProducto = ProductModel(
                etiquetaId: etiquetaId,
                nombre: nombre,
                cantidad: cantidad,
                ubicacion: ubicacion,
                usuarioId: usuarioId,
              );

              // Intentar agregar el producto
              final agregado =
                  await agregarProducto(inventarioId, nuevoProducto);

              Navigator.of(context).pop(); // Cierra el diálogo

              // Notificar resultado
              if (agregado) {
                print("producto agregado correctamente");
              } else {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'No se pudo agregar el producto, verifica los datos.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  Future<void> savePickingData(
    String tableName,
    List<ProductModel> scannedProducts,
    String userId,
  ) async {
    if (scannedProducts.isEmpty) {
      // Si la lista está vacía, no guardar y mostrar un mensaje
      print('No se han escaneado productos.');
      return;
    }

    try {
      // Obtener la referencia del documento de inventario
      final collectionRef =
          FirebaseFirestore.instance.collection('inventarios');
      final tableRef =
          collectionRef.doc(tableName); // Seleccionar el documento de la tabla

      // Crear un nuevo documento en la subcolección 'pickings'
      final pickingRef = tableRef
          .collection('pickings')
          .doc(); // Doc nuevo generado automáticamente

      // Crear el objeto para guardar los datos
      final pickingData = {
        'productos': scannedProducts.map((product) => product.toMap()).toList(),
        'fecha': Timestamp.now(),
        'usuarioId': userId,
      };

      // Guardar el documento en Firestore
      await pickingRef.set(pickingData);
      print('Picking guardado correctamente en Firestore');
    } catch (e) {
      print('Error al guardar el picking: $e');
    }
  }
}

class Notificacion {
  static void show(BuildContext context, String message,
      {Color color = Colors.blue}) {
    ScaffoldMessenger.of(context)
        .clearSnackBars(); // Limpia los SnackBars activos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}

class MockNfcTag {
  final String id; // Simulamos el ID de la etiqueta NFC

  MockNfcTag({required this.id});
}
