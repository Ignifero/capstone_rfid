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
  final ValueNotifier<bool> isFlashing = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _searchController.dispose();
    isFlashing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => InventarioViewModel()..fetchTables(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Selecciona una tabla'),
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
                      // Botón que parpadea intermitentemente
                      AnimatedBuilder(
                        animation: isFlashing,
                        builder: (context, child) {
                          return ElevatedButton(
                            onPressed: () async {
                              if (viewModel.selectedTableName != null) {
                                // Inicia el parpadeo
                                isFlashing.value = true;

                                // Temporizador para alternar el color
                                Timer.periodic(Duration(milliseconds: 500),
                                    (timer) {
                                  if (!isFlashing.value) {
                                    timer.cancel(); // Detiene el temporizador
                                  } else {
                                    setState(() {}); // Fuerza el redibujado
                                  }
                                });

                                // Llama al método que maneja el escaneo NFC
                                await context
                                    .read<InventarioViewModel>()
                                    .scanNfcAndAddProduct(
                                      context,
                                      viewModel.selectedTableName!,
                                    );

                                // Detiene el parpadeo después de la ejecución
                                isFlashing.value = false;
                              } else {
                                // Control de notificaciones duplicadas
                                ScaffoldMessenger.of(context)
                                    .clearSnackBars(); // Limpia cualquier SnackBar existente
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'DEBES SELECCIONAR UNA TABLA PRIMERO .'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Text('+ Producto'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              textStyle: TextStyle(fontSize: 12),
                              backgroundColor: isFlashing.value
                                  ? Colors.green
                                  : Colors.blue, // Alterna entre verde y azul
                            ),
                          );
                        },
                      ),
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
                      setState(() {});
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

                        // Filtra los productos según el texto de búsqueda
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

  // Método para mostrar el cuadro de diálogo para crear una tabla
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

                // Mostrar notificación de éxito
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('INVENTARIO CREADO CORRECTAMENTE.'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Cerrar el diálogo después de crear la tabla
                Navigator.of(context).pop();
              } else {
                // Mostrar notificación de error
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

  // Método para mostrar el cuadro de diálogo para agregar un producto
  void _showAddProductDialog(
      BuildContext context, InventarioViewModel viewModel, String etiquetaId) {
    final nombreController = TextEditingController();
    final cantidadController = TextEditingController();
    final ubicacionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar nuevo producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre del producto'),
            ),
            TextField(
              controller: cantidadController,
              decoration: InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: ubicacionController,
              decoration: InputDecoration(labelText: 'Ubicación'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final nombre = nombreController.text.trim();
              final cantidad = int.tryParse(cantidadController.text) ?? 0;
              final ubicacion = ubicacionController.text.trim();

              if (nombre.isEmpty || cantidad <= 0 || ubicacion.isEmpty) {
                // Control de notificaciones duplicadas
                ScaffoldMessenger.of(context)
                    .clearSnackBars(); // Limpia cualquier SnackBar existente
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('POR FAVOR COMPLETA TODOS LOS CAMPOS.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Agregar el producto utilizando el viewModel
              await viewModel.agregarProducto(
                viewModel.selectedTableName!, // ID de la tabla o inventario
                ProductModel(
                  etiquetaId: etiquetaId, // Usamos el ID de la etiqueta NFC
                  nombre: nombre,
                  cantidad: cantidad,
                  ubicacion: ubicacion,
                ),
              );

              // Control de notificaciones duplicadas
              ScaffoldMessenger.of(context)
                  .clearSnackBars(); // Limpia cualquier SnackBar existente
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('PRODUCTO CREADO CORRECTAMENTE .'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
