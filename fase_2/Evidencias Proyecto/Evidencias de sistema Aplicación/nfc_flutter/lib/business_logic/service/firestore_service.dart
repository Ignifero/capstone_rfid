// business_logic/service/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _inventarioCollection =
      FirebaseFirestore.instance.collection('inventario');

  // Obtener todos los items de inventario
  Stream<List<Map<String, dynamic>>> getInventario() {
    return _inventarioCollection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList());
  }

  // Crear nuevo item de inventario
  Future<void> addItem(Map<String, dynamic> data) async {
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
