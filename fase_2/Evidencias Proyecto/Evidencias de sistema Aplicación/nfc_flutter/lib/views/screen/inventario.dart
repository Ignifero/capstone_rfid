import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_flutter/viewmodels/inventario_viewmodel.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventarioViewModel = Provider.of<InventarioViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      body: ListView.builder(
        itemCount: inventarioViewModel.inventario.length,
        itemBuilder: (context, index) {
          final item = inventarioViewModel.inventario[index];
          return ListTile(
            title: Text(item['nombre']),
            subtitle: Text(
                'Cantidad: ${item['cantidad']} - Ubicación: ${item['ubicacion']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                // Llama a la función de eliminar
                inventarioViewModel.deleteItem(item['id']);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController cantidadController = TextEditingController();
    final TextEditingController ubicacionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: cantidadController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: ubicacionController,
                decoration: const InputDecoration(labelText: 'Ubicación'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Lógica para agregar el producto
                final String nombre = nombreController.text;
                final int cantidad = int.tryParse(cantidadController.text) ?? 0;
                final String ubicacion = ubicacionController.text;

                if (nombre.isNotEmpty && cantidad > 0 && ubicacion.isNotEmpty) {
                  final nuevoProducto = {
                    'nombre': nombre,
                    'cantidad': cantidad,
                    'ubicacion': ubicacion,
                    // Agrega el ID o cualquier otro campo necesario
                  };
                  Provider.of<InventarioViewModel>(context, listen: false)
                      .addItem(nuevoProducto);
                  Navigator.of(context).pop(); // Cierra el diálogo
                }
              },
              child: const Text('Agregar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }
}
