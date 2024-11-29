import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Variable global para inventarioId
  final String inventarioId = 'inventarios'; // Declaración global

// Método para obtener productos de un inventario específico
  // Método para obtener productos de un inventario específico
  Stream<List<ProductModel>> fetchProductos(String inventarioId) {
    print(
        'Fetching productos para inventario: $inventarioId'); // Depuración: mostrando el ID del inventario

    return _firestore
        .collection('inventarios') // Colección de inventarios
        .doc(inventarioId) // Documento del inventario específico
        .collection('productos') // Colección de productos dentro del inventario
        .snapshots() // Escucha los cambios en tiempo real
        .map((snapshot) {
      // Depuración: mostrar el tamaño de la colección de productos
      print('Número de productos en la colección: ${snapshot.docs.length}');

      return snapshot.docs.map((doc) {
        // Depuración: imprimir los datos del documento
        print('Producto encontrado: ${doc.data()}');

        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Método para listar inventarios (tablas)
  Future<List<String>> listInventarios() async {
    try {
      final querySnapshot = await _firestore.collection('inventarios').get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print("Error al obtener inventarios: $e");
      return [];
    }
  }

  // Obtiene las tablas desde Firestore
  Future<List<String>> listTables(String inventarioId) async {
    try {
      print("Consultando Firestore para obtener las tablas...");
      final collectionReference = _firestore.collection(inventarioId);
      final snapshot = await collectionReference.get();
      List<String> tablas = snapshot.docs.map((doc) => doc.id).toList();
      print("Tablas obtenidas: $tablas");
      return tablas;
    } catch (e) {
      print("Error al obtener las tablas: $e");
      return [];
    }
  }

  // FirestoreService - Método para agregar un producto a la subcolección de productos
  Future<void> addProductToCollection(
      String inventarioId, String tableName, ProductModel product) async {
    try {
      print('Agregando producto a la colección');
      print('Ruta de acceso: inventarios/$inventarioId/$tableName/productos');

      await FirebaseFirestore.instance
          .collection(
              'inventarios') // Asegúrate de que esto siempre apunte a la colección principal
          .doc(inventarioId) // Documento del inventario específico
          .collection('productos') // Subcolección de productos
          .add({
        'etiquetaId': product.etiquetaId,
        'nombre': product.nombre,
        'cantidad': product.cantidad,
        'ubicacion': product.ubicacion,
      });

      print('Producto agregado correctamente');
    } catch (e) {
      print('Error al agregar producto: $e');
      throw e;
    }
  }

  // Crear tabla (colección)
  Future<void> createTable(String inventarioId, String tableName) async {
    try {
      await _firestore.collection(inventarioId).doc(tableName).set({
        'createdAt': FieldValue.serverTimestamp(),
      });
      print(
          "Tabla '$tableName' creada correctamente en la colección '$inventarioId'.");
    } catch (e) {
      print("Error al crear la tabla '$tableName': $e");
      throw Exception("Error al crear la tabla.");
    }
  }

  // Método para verificar si un producto ya existe en el inventario específico del usuario
  Future<bool> checkIfProductExistsInSpecificInventario(
      String etiquetaId) async {
    try {
      // Obtener el usuario autenticado
      final usuarioId = FirebaseAuth.instance.currentUser?.uid;
      if (usuarioId == null) {
        print("Usuario no autenticado");
        return false; // Si no hay usuario autenticado, no se puede verificar
      }

      // Consultar la subcolección de productos en el inventario específico
      final inventarioRef = _firestore
          .collection('usuarios') // Colección de usuarios
          .doc(usuarioId) // Documento del usuario actual
          .collection('inventarios') // Colección de inventarios
          .doc('inventarioId') // Aquí agregamos el ID del inventario
          .collection('productos'); // Subcolección de productos

      final docSnapshot =
          await inventarioRef.where('etiquetaId', isEqualTo: etiquetaId).get();

      return docSnapshot.docs.isNotEmpty; // Si el producto ya existe
    } catch (e) {
      print("Error al verificar producto en inventario: $e");
      return false;
    }
  }

  Future<ProductModel?> getProductDetails(
      String inventarioId, String etiquetaId) async {
    try {
      final inventoryRef = _firestore.collection(inventarioId);
      final querySnapshot = await inventoryRef.get();

      for (var doc in querySnapshot.docs) {
        final productosRef = doc.reference.collection('productos');
        final productoSnapshot =
            await productosRef.where('etiquetaId', isEqualTo: etiquetaId).get();

        if (productoSnapshot.docs.isNotEmpty) {
          final productData = productoSnapshot.docs.first.data();
          return ProductModel.fromMap(productData);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener detalles del producto: $e');
    }
  }

  // Verificar existencia de un producto en cualquier subcolección 'productos' dentro de los documentos de 'inventarios'
  Future<Map<String, dynamic>?> checkIfProductExistsInInventory(
      String inventarioId, String etiquetaId) async {
    try {
      final inventoryRef =
          _firestore.collection(inventarioId); // Colección de inventarios

      // Obtener todos los documentos dentro de la colección de inventarios
      final querySnapshot = await inventoryRef.get();

      // Iterar sobre cada documento (representando un inventario específico)
      for (var doc in querySnapshot.docs) {
        final productosRef =
            doc.reference.collection('productos'); // Subcolección 'productos'

        // Buscar en la subcolección 'productos' si el etiquetaId coincide
        final productoSnapshot = await productosRef
            .where('etiquetaId',
                isEqualTo: etiquetaId) // Buscar producto por etiquetaId
            .get();

        // Si se encuentra algún producto con ese etiquetaId, devuelve los detalles
        if (productoSnapshot.docs.isNotEmpty) {
          // Extraemos los datos del primer producto encontrado
          final productData = productoSnapshot.docs.first.data();
          return productData; // Devuelve los detalles del producto
        }
      }

      // Si no se encuentra en ninguna subcolección, devuelve null
      return null;
    } catch (e) {
      print('Error al verificar el producto: $e');
      return null;
    }
  }
}
