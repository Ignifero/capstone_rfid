import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nfc_flutter/viewmodels/inventario_viewmodel.dart';

class InventarioScreen extends StatelessWidget {
  const InventarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Accediendo al InventarioViewModel
    final inventarioViewModel = Provider.of<InventarioViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: inventarioViewModel.items.isEmpty
            ? const Center(child: Text('No hay productos en el inventario.'))
            : ListView.builder(
                itemCount: inventarioViewModel.items.length,
                itemBuilder: (context, index) {
                  final producto = inventarioViewModel.items[index];
                  return ListTile(
                    title: Text(producto.nombre),
                    subtitle: Text('Cantidad: ${producto.cantidad}'),
                    trailing: Text('Ubicación: ${producto.ubicacion}'),
                    onTap: () {
                      // Aquí puedes agregar lógica adicional si es necesario
                    },
                  );
                },
              ),
      ),
    );
  }
}
