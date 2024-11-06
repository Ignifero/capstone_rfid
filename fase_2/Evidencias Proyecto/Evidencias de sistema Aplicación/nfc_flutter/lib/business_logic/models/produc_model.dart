class ProductModel {
  final String id;
  final String nombre;
  final int cantidad;
  final String ubicacion;

  ProductModel({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.ubicacion,
  });

  // Método para convertir el modelo a un JSON para Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
      'ubicacion': ubicacion,
    };
  }

  // Método para crear un modelo a partir de un JSON de Firestore
  factory ProductModel.fromJson(String id, Map<String, dynamic> json) {
    return ProductModel(
      id: id,
      nombre: json['nombre'] ?? '',
      cantidad: json['cantidad'] ?? 0,
      ubicacion: json['ubicacion'] ?? '',
    );
  }
}
