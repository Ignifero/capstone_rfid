import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_flutter/viewmodels/inventario_viewmodel.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventarioViewModel = Provider.of<InventarioViewModel>(context);

    Future.delayed(Duration.zero, () async {
      await inventarioViewModel.fetchInventory();
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Inventario')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Lista de productos en el inventario.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: inventarioViewModel.inventario.length,
              itemBuilder: (context, index) {
                final item = inventarioViewModel.inventario[index];
                return ListTile(
                  title: Text(item.nombre),
                  subtitle: Text(
                      'Cantidad: ${item.cantidad} - Ubicación: ${item.ubicacion}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      inventarioViewModel.deleteItem(item.id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navegar a la pantalla de escaneo
          Navigator.pushNamed(context, '/scanner');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
