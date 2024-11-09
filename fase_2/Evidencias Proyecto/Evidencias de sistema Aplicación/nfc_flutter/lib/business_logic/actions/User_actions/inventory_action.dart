// business_logic/actions/User_actions/inventory_action.dart
import 'package:nfc_flutter/business_logic/service/firestore_service.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';

class InventoryAction {
  final FirestoreService firestoreService;

  InventoryAction({required this.firestoreService});

  // Método para obtener todos los productos del inventario desde Firestore
  Stream<List<ProductModel>> getInventario() {
    return firestoreService.getInventario();
  }

  // Método para agregar un producto
  Future<void> addProduct(Map<String, dynamic> productMap) async {
    await firestoreService.addProduct(productMap);
  }

  // Verifica si un producto ya existe en Firestore usando el ID de la etiqueta NFC
  Future<bool> checkIfProductExists(String productId) async {
    return await firestoreService.checkIfProductExists(productId);
  }
}
