import 'package:flutter/material.dart';
import 'package:nfc_flutter/business_logic/service/firestore_service.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';

class InventarioViewModel extends ChangeNotifier {
  final FirestoreService firestoreService;
  List<ProductModel> inventario = [];

  InventarioViewModel(this.firestoreService);

  Future<void> fetchInventory() async {
    inventario = await firestoreService.getInventory();
    notifyListeners();
  }

  Future<bool> checkIfExists(String id) async {
    return await firestoreService.checkIfProductExists(id);
  }

  Future<void> addItem(ProductModel producto) async {
    await firestoreService.addProduct(producto);
    inventario.add(producto);
    notifyListeners();
  }

  Future<void> deleteItem(String id) async {
    await firestoreService.deleteProduct(id);
    inventario.removeWhere((producto) => producto.id == id);
    notifyListeners();
  }
}
