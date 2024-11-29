import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_flutter/viewmodels/scanner_viewmodel.dart';

class ScannerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scannerViewModel = Provider.of<ScannerViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Escanea la etiqueta Nfc'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (scannerViewModel.isScanning)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () {
                  scannerViewModel.scanNfcAndCheckProduct(context);
                },
                child: Text('Escanear NFC'),
              ),
          ],
        ),
      ),
    );
  }
}
