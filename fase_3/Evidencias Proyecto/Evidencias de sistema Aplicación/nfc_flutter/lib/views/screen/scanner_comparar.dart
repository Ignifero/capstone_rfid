import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_flutter/viewmodels/inventario_viewmodel.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';

class PickingScreen extends StatefulWidget {
  @override
  _PickingScreenState createState() => _PickingScreenState();
}

class _PickingScreenState extends State<PickingScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> isFlashing = ValueNotifier<bool>(false);
  final List<ProductModel> _scannedProducts = [];

  String?
      _currentTableName; // Variable para controlar el inventario seleccionado

  @override
  void dispose() {
    _searchController.dispose();
    isFlashing.dispose();
    super.dispose();
  }

  void _addScannedProduct(ProductModel product) {
    setState(() {
      if (!_scannedProducts.any((p) => p.etiquetaId == product.etiquetaId)) {
        _scannedProducts.add(product); // Agregar solo si no está en la lista
      }
    });
  }

  void _resetScannedProducts(String newTableName) {
    if (_currentTableName != newTableName) {
      setState(() {
        _scannedProducts.clear();
        _currentTableName = newTableName; // Actualizamos la tabla actual
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventarioViewModel()..fetchTables(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Picking de Inventario'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<InventarioViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return Center(child: CircularProgressIndicator());
              }

              if (viewModel.inventarios.isEmpty) {
                return Center(child: Text('No hay inventarios disponibles.'));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selector de tabla y botón de escaneo
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: viewModel.selectedTableName,
                          hint: Text('Selecciona una tabla'),
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
                      AnimatedBuilder(
                        animation: isFlashing,
                        builder: (context, child) {
                          return ElevatedButton(
                            onPressed: () async {
                              if (viewModel.selectedTableName != null) {
                                isFlashing.value = true;

                                Timer.periodic(Duration(milliseconds: 500),
                                    (timer) {
                                  if (!isFlashing.value) {
                                    timer.cancel();
                                  } else {
                                    setState(() {});
                                  }
                                });

                                // Escanear y validar producto
                                final scannedProduct = await context
                                    .read<InventarioViewModel>()
                                    .scanAndCompareProduct(
                                        viewModel.selectedTableName!, context);

                                if (scannedProduct != null) {
                                  _addScannedProduct(scannedProduct);
                                }

                                isFlashing.value = false;
                              } else {
                                // Control de notificaciones duplicadas
                                ScaffoldMessenger.of(context)
                                    .clearSnackBars(); // Limpia cualquier SnackBar existente
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'DEBES SELECCIONAR UNA TABLA PRIMERO.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text('Escanear'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              textStyle: TextStyle(fontSize: 12),
                              backgroundColor:
                                  isFlashing.value ? Colors.green : Colors.blue,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Contenedor de productos escaneados
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
                          if (_scannedProducts.isNotEmpty ||
                              viewModel.selectedTableName != null)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Escaneados: ${_scannedProducts.length} / ${viewModel.productosTotales}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
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
                                      'Productos Escaneados',
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
                                        margin:
                                            EdgeInsets.symmetric(vertical: 4),
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
                        ],
                      ),
                    ),

                  // Lista de productos de la base de datos
                  Expanded(
                    child: FutureBuilder<List<ProductModel>>(
                      future: viewModel.selectedTableName != null &&
                              viewModel.selectedTableName!.isNotEmpty
                          ? viewModel.fetchProductosOnce(viewModel
                              .selectedTableName!) // Solo hace fetch si la tabla está seleccionada
                          : Future.error(
                              'No se ha seleccionado una tabla'), // Lanza un error si no hay tabla seleccionada
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        // Si hay un error (por ejemplo, no se seleccionó tabla), muestra el error en pantalla
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }

                        // Filtrar productos según el texto de búsqueda
                        final filteredProducts = snapshot.data
                                ?.where((product) => product.nombre
                                    .toLowerCase()
                                    .contains(
                                        _searchController.text.toLowerCase()))
                                .toList() ??
                            [];

                        // Si no hay productos que coincidan con la búsqueda
                        if (filteredProducts.isEmpty) {
                          return Center(
                              child: Text('No hay productos que coincidan.'));
                        }

                        // Mostrar los productos filtrados
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
