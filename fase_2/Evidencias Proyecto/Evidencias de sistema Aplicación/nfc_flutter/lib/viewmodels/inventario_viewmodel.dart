import 'package:flutter/material.dart';
import 'package:nfc_flutter/business_logic/service/firestore_service.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';
import 'package:nfc_flutter/business_logic/actions/User_actions/inventory_action.dart';
import 'package:nfc_flutter/business_logic/actions/User_actions/nfc_action.dart';

class InventarioViewModel extends ChangeNotifier {
  final InventoryAction _inventoryAction;
  final NFCAction _nfcAction;
  final FirestoreService firestoreService;
  List<ProductModel> _inventario = [];

  // Getter para obtener los productos del inventario
  List<ProductModel> get items => _inventario;

  // Constructor para inicializar las dependencias
  InventarioViewModel(
      this._inventoryAction, this._nfcAction, this.firestoreService) {
    _initializeInventoryStream();
  }

  // Método que inicializa el stream para actualizar el inventario
  void _initializeInventoryStream() {
    _inventoryAction.getInventario().listen((newInventory) {
      _inventario = newInventory; // Asignamos los nuevos productos
      notifyListeners(); // Notificamos a los listeners (como InventarioScreen)
    });
  }

  /// Acción que verifica soporte NFC, escanea y agrega el producto si no existe
  // En InventarioViewModel, dentro de scanAndAddProduct
  Future<void> scanAndAddProduct(BuildContext context) async {
    // Verifica si el dispositivo es compatible con NFC
    final nfcSupported = await _nfcAction.checkNFCSupport();
    if (!nfcSupported) {
      _showNotification(context, "Dispositivo no compatible con NFC");
      return;
    }

    // Escanea el producto mediante NFC
    final productId = await _nfcAction.scanNFC();
    if (productId == null) {
      _showNotification(context, "Error al leer la etiqueta NFC");
      return;
    }

    // Verifica si el producto ya existe en el inventario
    final exists = await _inventoryAction.checkIfProductExists(productId);
    if (exists) {
      _showNotification(context, "El producto ya existe en el inventario");
    } else {
      // Si no existe, se pasa el producto ingresado a la acción de agregarlo
      _showNotification(context, "Producto agregado exitosamente");
    }
  }

  // Mostrar notificaciones en el Scaffold
  void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      // Convertir el ProductModel a Map<String, dynamic>
      final Map<String, dynamic> productMap = product.toMap();

      // Llamar al servicio de Firestore para agregar el producto
      await _inventoryAction.addProduct(productMap);

      // Actualizar el inventario local (si es necesario)
      _inventario.add(product); // O actualizar el inventario desde Firestore
      notifyListeners(); // Notificar a la UI
    } catch (e) {
      print("Error al agregar el producto: $e");
      throw Exception("No se pudo agregar el producto.");
    }
  }

  // Método adicional para verificar si el producto existe (renombrado)
  Future<bool> checkIfProductExists(String productId) async {
    return await _inventoryAction.checkIfProductExists(productId);
  }
}
