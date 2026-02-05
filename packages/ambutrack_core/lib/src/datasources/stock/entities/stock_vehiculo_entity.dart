/// Entidad de dominio para stock de vehículo
///
/// Representa el stock actual de un producto en un vehículo específico
class StockVehiculoEntity {
  /// Identificador único del registro de stock
  final String id;

  /// ID del vehículo
  final String vehiculoId;

  /// ID del producto
  final String productoId;

  /// Cantidad actual en stock
  final int cantidadActual;

  /// Cantidad mínima requerida (de la vista)
  final int? cantidadMinima;

  /// Fecha de caducidad del producto
  final DateTime? fechaCaducidad;

  /// Número de lote
  final String? lote;

  /// Ubicación del producto en el vehículo
  final String? ubicacion;

  /// Observaciones adicionales
  final String? observaciones;

  /// Fecha de última actualización
  final DateTime updatedAt;

  /// ID del usuario que actualizó
  final String? updatedBy;

  // Campos adicionales de la vista v_stock_vehiculo_estado

  /// Matrícula del vehículo (de la vista)
  final String? matricula;

  /// Tipo de vehículo (A2, B, C)
  final String? tipoVehiculo;

  /// Nombre del producto (de la vista)
  final String? productoNombre;

  /// Nombre comercial del producto (de la vista)
  final String? nombreComercial;

  /// Código de categoría (de la vista)
  final String? categoriaCodigo;

  /// Nombre de categoría (de la vista)
  final String? categoriaNombre;

  /// Estado del stock: 'ok', 'bajo', 'sin_stock'
  final String? estadoStock;

  /// Estado de caducidad: 'ok', 'proximo', 'critico', 'caducado', 'sin_caducidad'
  final String? estadoCaducidad;

  const StockVehiculoEntity({
    required this.id,
    required this.vehiculoId,
    required this.productoId,
    required this.cantidadActual,
    this.cantidadMinima,
    this.fechaCaducidad,
    this.lote,
    this.ubicacion,
    this.observaciones,
    required this.updatedAt,
    this.updatedBy,
    this.matricula,
    this.tipoVehiculo,
    this.productoNombre,
    this.nombreComercial,
    this.categoriaCodigo,
    this.categoriaNombre,
    this.estadoStock,
    this.estadoCaducidad,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockVehiculoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vehiculoId == other.vehiculoId &&
          productoId == other.productoId &&
          cantidadActual == other.cantidadActual &&
          cantidadMinima == other.cantidadMinima &&
          fechaCaducidad == other.fechaCaducidad &&
          lote == other.lote &&
          ubicacion == other.ubicacion &&
          observaciones == other.observaciones &&
          estadoStock == other.estadoStock &&
          estadoCaducidad == other.estadoCaducidad;

  @override
  int get hashCode =>
      id.hashCode ^
      vehiculoId.hashCode ^
      productoId.hashCode ^
      cantidadActual.hashCode ^
      cantidadMinima.hashCode ^
      fechaCaducidad.hashCode ^
      lote.hashCode ^
      ubicacion.hashCode ^
      observaciones.hashCode ^
      estadoStock.hashCode ^
      estadoCaducidad.hashCode;

  @override
  String toString() =>
      'StockVehiculoEntity(id: $id, producto: $productoNombre, cantidad: $cantidadActual)';
}
