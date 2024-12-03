class ProductModel {
  final String nombre;
  final String etiquetaId;
  final int cantidad;
  final String ubicacion;
  final String usuarioId; // Nuevo campo

  ProductModel({
    required this.nombre,
    required this.etiquetaId,
    required this.cantidad,
    required this.ubicacion,
    required this.usuarioId, // Asegura que el modelo tenga este campo
  });

  // Convertir el mapa en un objeto ProductModel
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      nombre: map['nombre'] ?? 'Sin nombre',
      etiquetaId: map['etiquetaId'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      ubicacion: map['ubicacion'] ?? 'Sin ubicación',
      usuarioId:
          map['usuarioId'] ?? '', // Incluir el usuarioId al construir el objeto
    );
  }

  // Convertir el objeto ProductModel a un mapa
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'etiquetaId': etiquetaId,
      'cantidad': cantidad,
      'ubicacion': ubicacion,
      'usuarioId': usuarioId, // Incluir el usuarioId al serializar
    };
  }
}
