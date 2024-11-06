import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';

class FirestoreService {
  final CollectionReference _productCollection =
      FirebaseFirestore.instance.collection('inventario');

  Future<List<ProductModel>> getInventory() async {
    final querySnapshot = await _productCollection.get();
    return querySnapshot.docs
        .map((doc) =>
            ProductModel.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<bool> checkIfProductExists(String id) async {
    final doc = await _productCollection.doc(id).get();
    return doc.exists;
  }

  Future<void> addProduct(ProductModel producto) async {
    await _productCollection.doc(producto.id).set(producto.toJson());
  }

  Future<void> deleteProduct(String id) async {
    await _productCollection.doc(id).delete();
  }
}
