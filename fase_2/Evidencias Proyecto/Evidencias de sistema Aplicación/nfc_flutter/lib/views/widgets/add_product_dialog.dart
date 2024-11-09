import 'package:flutter/material.dart';

class AddProductDialog extends StatelessWidget {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Agregar nuevo producto"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nombreController,
            decoration: InputDecoration(labelText: "Nombre del producto"),
          ),
          TextField(
            controller: cantidadController,
            decoration: InputDecoration(labelText: "Cantidad"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: ubicacionController,
            decoration: InputDecoration(labelText: "Ubicación"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra sin guardar
          },
          child: Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              "nombre": nombreController.text,
              "cantidad": int.tryParse(cantidadController.text) ?? 1,
              "ubicacion": ubicacionController.text,
            });
          },
          child: Text("Guardar"),
        ),
      ],
    );
  }
}
