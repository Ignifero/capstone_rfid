import 'package:cloud_firestore/cloud_firestore.dart';

class Inventario {
  final String nombre;
  final String usuarioId;
  final Timestamp fechaCreacion;

  Inventario(
      {required this.nombre,
      required this.usuarioId,
      required this.fechaCreacion});

  // Método para mapear los datos de Firestore a la clase Inventario
  factory Inventario.fromMap(Map<String, dynamic> data) {
    return Inventario(
      nombre: data['nombre'] ?? '',
      usuarioId: data['usuarioId'] ?? '',
      fechaCreacion: data['fecha_creacion'],
    );
  }
}
