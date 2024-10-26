// business_logic/view_model/inventario_view_model.dart
import 'package:flutter/material.dart';
import 'package:nfc_flutter/business_logic/service/firestore_service.dart';

class InventarioViewModel extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Map<String, dynamic>> _inventario = [];

  InventarioViewModel(this._firestoreService) {
    _fetchInventario();
  }

  List<Map<String, dynamic>> get inventario => _inventario;

  void _fetchInventario() {
    _firestoreService.getInventario().listen((inventarioData) {
      _inventario = inventarioData;
      notifyListeners();
    });
  }

  Future<void> addItem(Map<String, dynamic> data) async {
    await _firestoreService.addItem(data);
  }

  Future<void> updateItem(String id, Map<String, dynamic> data) async {
    await _firestoreService.updateItem(id, data);
  }

  Future<void> deleteItem(String id) async {
    await _firestoreService.deleteItem(id);
  }
}
