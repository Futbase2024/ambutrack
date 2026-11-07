/// Entidad de dominio para stock mínimo por tipo de vehículo
///
/// Define el stock mínimo requerido de cada producto según el tipo de ambulancia
class StockMinimoEntity {
  /// Identificador único del registro
  final String id;

  /// ID del producto
  final String productoId;

  /// Tipo de vehículo (A2, B, C)
  final String tipoVehiculo;

  /// Cantidad mínima requerida
  final int cantidadMinima;

  /// Cantidad recomendada
  final int? cantidadRecomendada;

  /// Indica si es obligatorio
  final bool obligatorio;

  const StockMinimoEntity({
    required this.id,
    required this.productoId,
    required this.tipoVehiculo,
    required this.cantidadMinima,
    this.cantidadRecomendada,
    this.obligatorio = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockMinimoEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          productoId == other.productoId &&
          tipoVehiculo == other.tipoVehiculo &&
          cantidadMinima == other.cantidadMinima &&
          cantidadRecomendada == other.cantidadRecomendada &&
          obligatorio == other.obligatorio;

  @override
  int get hashCode =>
      id.hashCode ^
      productoId.hashCode ^
      tipoVehiculo.hashCode ^
      cantidadMinima.hashCode ^
      cantidadRecomendada.hashCode ^
      obligatorio.hashCode;

  @override
  String toString() =>
      'StockMinimoEntity(id: $id, tipo: $tipoVehiculo, min: $cantidadMinima)';
}
