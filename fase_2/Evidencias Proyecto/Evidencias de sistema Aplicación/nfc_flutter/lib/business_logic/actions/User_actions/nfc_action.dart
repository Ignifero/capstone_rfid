import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NFCAction {
  /// Verifica si el dispositivo soporta NFC
  Future<bool> checkNFCSupport() async {
    return await FlutterNfcKit.nfcAvailability != NFCAvailability.not_supported;
  }

  /// Escanea la etiqueta NFC y retorna un ID de producto
  Future<String?> scanNFC() async {
    try {
      await FlutterNfcKit.poll(); // Activa el escaneo
      final nfcTag = await FlutterNfcKit.transceive(
          "Leer etiqueta"); // Lee la etiqueta (simulado)
      await FlutterNfcKit.finish(); // Termina el escaneo
      return nfcTag; // Retorna el ID del producto obtenido
    } catch (e) {
      print("Error al leer NFC: $e");
      return null;
    }
  }
}
