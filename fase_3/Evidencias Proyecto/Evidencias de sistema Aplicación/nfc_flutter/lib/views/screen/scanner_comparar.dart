import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:nfc_flutter/viewmodels/inventario_viewmodel.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PickingScreen extends StatefulWidget {
  @override
  _PickingScreenState createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<ProductModel> _scannedProducts = [];
  bool isProcessing = false; // Bandera para mostrar spinner en el botón
  String? _currentTableName;

  String? get usuarioId => FirebaseAuth.instance.currentUser?.uid;
  String? get userEmail => FirebaseAuth.instance.currentUser?.email;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addScannedProduct(ProductModel product) {
    setState(() {
      if (!_scannedProducts.any((p) => p.etiquetaId == product.etiquetaId)) {
        _scannedProducts.add(product);
      }
    });
  }

  void _resetScannedProducts(String newTableName) {
    if (_currentTableName != newTableName) {
      setState(() {
        _scannedProducts.clear();
        _currentTableName = newTableName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventarioViewModel()..fetchTables(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Comienza un picking'),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer<InventarioViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.inventarios.isEmpty) {
                    return Center(
                        child: Text('No hay inventarios disponibles.'));
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: viewModel.selectedTableName,
                              hint: Text('Inventarios'),
                              items: viewModel.inventarios.map((inventario) {
                                return DropdownMenuItem<String>(
                                  value: inventario.nombre,
                                  child: Text(inventario.nombre),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  _resetScannedProducts(newValue);
                                  viewModel.selectTable(newValue);
                                  viewModel.fetchProductosOnce(newValue);
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () async {
                              if (viewModel.selectedTableName != null) {
                                setState(() => isProcessing = true);

                                try {
                                  final scannedProduct = await context
                                      .read<InventarioViewModel>()
                                      .scanAndCompareProduct(
                                          viewModel.selectedTableName!,
                                          context);

                                  if (scannedProduct != null) {
                                    _addScannedProduct(scannedProduct);
                                  }
                                } finally {
                                  setState(() => isProcessing = false);
                                }
                              } else {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'DEBES SELECCIONAR UNA TABLA PRIMERO.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: isProcessing
                                ? CircularProgressIndicator(
                                    color: Colors.blue,
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.nfc,
                                          size: 20.0, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text(
                                        'Agregar',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide.none,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (_scannedProducts.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Escaneados: ${_scannedProducts.length} / ${viewModel.productosTotales}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _scannedProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _scannedProducts[index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    elevation: 3,
                                    child: ListTile(
                                      title: Text(product.nombre),
                                      subtitle: Text(
                                          'Cantidad: ${product.cantidad}, Ubicación: ${product.ubicacion}'),
                                      trailing: Icon(Icons.check_circle,
                                          color: Colors.green),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: FutureBuilder<List<ProductModel>>(
                          future: viewModel.selectedTableName != null &&
                                  viewModel.selectedTableName!.isNotEmpty
                              ? viewModel.fetchProductosOnce(
                                  viewModel.selectedTableName!)
                              : Future.error('No se ha seleccionado una tabla'),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            final filteredProducts = snapshot.data
                                    ?.where((product) => product.nombre
                                        .toLowerCase()
                                        .contains(_searchController.text
                                            .toLowerCase()))
                                    .toList() ??
                                [];

                            if (filteredProducts.isEmpty) {
                              return Center(
                                  child:
                                      Text('No hay productos que coincidan.'));
                            }

                            return ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  elevation: 3,
                                  child: ListTile(
                                    title: Text(product.nombre),
                                    subtitle: Text(
                                        'Cantidad: ${product.cantidad}, Ubicación: ${product.ubicacion}'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (viewModel.selectedTableName != null) {
                              if (_scannedProducts.isEmpty) {
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'No se ha realizado ningún picking.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() => isProcessing = true);

                              try {
                                await viewModel.savePickingData(
                                  viewModel.selectedTableName!,
                                  _scannedProducts,
                                  usuarioId ?? 'usuario_desconocido',
                                );

                                await generatePickingReport(_scannedProducts);

                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Picking guardado correctamente y reporte generado.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } finally {
                                setState(() => isProcessing = false);
                              }
                            } else {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'DEBES SELECCIONAR UNA TABLA PRIMERO.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: isProcessing
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Generar Picking',
                                  style: TextStyle(fontSize: 16),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> generatePickingReport(List<ProductModel> scannedProducts) async {
    final pdf = pw.Document();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/picking_report.pdf');
    final usuario = userEmail ?? 'usuario desconocido';

    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Column(
        children: [
          pw.Text('Reporte de Picking', style: pw.TextStyle(fontSize: 24)),
          pw.Text('Usuario: $usuario', style: pw.TextStyle(fontSize: 18)),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['ID Producto', 'Nombre', 'Cantidad', 'Ubicación'],
            data: scannedProducts
                .map((product) => [
                      product.etiquetaId,
                      product.nombre,
                      product.cantidad,
                      product.ubicacion
                    ])
                .toList(),
          ),
        ],
      );
    }));

    await file.writeAsBytes(await pdf.save());
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      return pdf.save();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reporte generado en ${file.path}')),
    );
  }
}
