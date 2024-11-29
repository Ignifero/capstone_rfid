class ProductModel {
  final String nombre;
  final String etiquetaId;
  final int cantidad;
  final String ubicacion;

  ProductModel({
    required this.nombre,
    required this.etiquetaId,
    required this.cantidad,
    required this.ubicacion,
  });

  // Convertir el mapa en un objeto ProductModel
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      nombre: map['nombre'] ?? 'Sin nombre',
      etiquetaId: map['etiquetaId'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      ubicacion: map['ubicacion'] ?? 'Sin ubicación',
    );
  }

  // Convertir el objeto ProductModel a un mapa
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'etiquetaId': etiquetaId,
      'cantidad': cantidad,
      'ubicacion': ubicacion,
    };
  }
}
