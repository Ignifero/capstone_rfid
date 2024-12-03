import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nfc_flutter/business_logic/models/produc_model.dart';
import 'package:nfc_flutter/viewmodels/inventario_viewmodel.dart';
import 'package:provider/provider.dart';

class InventarioScreen extends StatefulWidget {
  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading =
      true; // Esta variable controla el estado de la carga de datos

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventarioViewModel()..fetchTables(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Selecciona tu inventario'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Consumer<InventarioViewModel>(
            builder: (context, viewModel, child) {
              // Si los datos están cargando, mostrar un spinner por un tiempo breve
              if (isLoading) {
                Future.delayed(Duration(seconds: 2), () {
                  setState(() {
                    isLoading = false;
                  });
                });
                return Center(child: CircularProgressIndicator());
              }

              // Si no hay inventarios cargados, mostrar el botón para crear tabla
              if (viewModel.inventarios.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No hay inventarios disponibles.'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          _showCreateTableDialog(context, viewModel);
                        },
                        child: Text('+ Crear Tabla'),
                      ),
                    ],
                  ),
                );
              }

              // Si hay inventarios, mostrar la pantalla normal
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: viewModel.selectedTableName,
                          hint: Text('Seleccionar Inventario'),
                          items: viewModel.inventarios.map((inventario) {
                            return DropdownMenuItem<String>(
                              value: inventario.nombre,
                              child: Text(inventario.nombre),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              viewModel.selectTable(newValue);
                              viewModel.fetchProductosOnce(newValue);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          _showCreateTableDialog(context, viewModel);
                        },
                        child: Text('+ Tabla'),
                      ),
                      SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Selector<InventarioViewModel, bool>(
                            selector: (_, viewModel) => viewModel.isScanning,
                            builder: (_, isScanning, __) {
                              if (isScanning) {
                                return CircularProgressIndicator();
                              }
                              return IconButton(
                                onPressed: () async {
                                  if (viewModel.selectedTableName != null) {
                                    try {
                                      bool productAdded = await context
                                          .read<InventarioViewModel>()
                                          .scanNfcAndAddProduct(
                                            context,
                                            viewModel.selectedTableName!,
                                          );

                                      if (productAdded) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'PRODUCTO AGREGADO CORRECTAMENTE'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'ERROR AL AGREGAR EL PRODUCTO'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'ERROR DURANTE EL ESCANEO, DISPOSITIVO INCOMPATIBLE'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'DEBES SELECCIONAR UNA TABLA PRIMERO'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.nfc,
                                  size: 20.0,
                                  color: Colors.blue,
                                ),
                              );
                            },
                          ),
                          const Text(
                            'Agregar',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar productos',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(
                          () {}); // Actualiza la búsqueda al cambiar el texto
                    },
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: FutureBuilder<List<ProductModel>>(
                      future: viewModel.selectedTableName != null
                          ? viewModel
                              .fetchProductosOnce(viewModel.selectedTableName!)
                          : Future.error("No se ha seleccionado una tabla"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final filteredProducts = snapshot.data
                                ?.where((product) => product.nombre
                                    .toLowerCase()
                                    .contains(
                                        _searchController.text.toLowerCase()))
                                .toList() ??
                            [];

                        if (filteredProducts.isEmpty) {
                          return Center(child: Text('No hay productos.'));
                        }

                        return ListView.builder(
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return Card(
                              child: ListTile(
                                title: Text(product.nombre),
                                subtitle: Text(
                                  'Cantidad: ${product.cantidad}, Ubicación: ${product.ubicacion}',
                                ),
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

  void _showCreateTableDialog(
      BuildContext context, InventarioViewModel viewModel) {
    final tableNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Crear nueva tabla'),
        content: TextField(
          controller: tableNameController,
          decoration: InputDecoration(labelText: 'Nombre de la tabla'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final tableName = tableNameController.text.trim();
              if (tableName.isNotEmpty) {
                await viewModel.createNewTable("inventarios", tableName);

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('INVENTARIO CREADO CORRECTAMENTE.'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
                // Refrescar inventarios después de crear una nueva tabla
                await viewModel.fetchTables();
              } else {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'DEBES INGRESAR UN NOMBRE VÁLIDO PARA EL INVENTARIO.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Crear'),
          ),
        ],
      ),
    );
  }
}
