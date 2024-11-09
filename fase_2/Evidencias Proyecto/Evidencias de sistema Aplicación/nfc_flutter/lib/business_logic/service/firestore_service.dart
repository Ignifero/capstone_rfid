// business_logic/service/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';

class FirestoreService {
  final CollectionReference _inventarioCollection =
      FirebaseFirestore.instance.collection('inventario');

  // Obtener todos los items de inventario y convertirlos a ProductModel
  Stream<List<ProductModel>> getInventario() {
    return _inventarioCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Aquí estamos creando el objeto ProductModel a partir del Map
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Obtener items por etiquetaId
  Future<List<Map<String, dynamic>>> getItemsByEtiquetaId(
      String etiquetaId) async {
    final querySnapshot = await _inventarioCollection
        .where('etiquetaId', isEqualTo: etiquetaId)
        .get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  // Método para verificar si el producto ya existe
  Future<bool> checkIfProductExists(String etiquetaId) async {
    final productos = await getItemsByEtiquetaId(etiquetaId);
    return productos
        .isNotEmpty; // Retorna true si existe al menos un producto con ese etiquetaId
  }

  // Crear nuevo item de inventario
  Future<void> addProduct(Map<String, dynamic> data) async {
    await _inventarioCollection.add(data);
  }

  // Actualizar item existente
  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    await _inventarioCollection.doc(id).update(data);
  }

  // Eliminar item
  Future<void> deleteItem(String id) async {
    await _inventarioCollection.doc(id).delete();
  }
}
