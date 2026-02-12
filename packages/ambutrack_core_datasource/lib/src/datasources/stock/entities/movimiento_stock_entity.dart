/// Tipos de movimiento de stock
enum TipoMovimiento {
  /// Entrada de stock
  entrada,

  /// Salida de stock
  salida,

  /// Ajuste de stock
  ajuste,

  /// Producto caducado
  caducidad,

  /// Transferencia entre vehículos
  transferencia,
}

/// Extensión para convertir desde/hacia string
extension TipoMovimientoExtension on TipoMovimiento {
  /// Convierte el enum a string para la BD
  String toJson() {
    switch (this) {
      case TipoMovimiento.entrada:
        return 'entrada';
      case TipoMovimiento.salida:
        return 'salida';
      case TipoMovimiento.ajuste:
        return 'ajuste';
      case TipoMovimiento.caducidad:
        return 'caducidad';
      case TipoMovimiento.transferencia:
        return 'transferencia';
    }
  }

  /// Convierte desde string de la BD al enum
  static TipoMovimiento fromJson(String json) {
    switch (json) {
      case 'entrada':
        return TipoMovimiento.entrada;
      case 'salida':
        return TipoMovimiento.salida;
      case 'ajuste':
        return TipoMovimiento.ajuste;
      case 'caducidad':
        return TipoMovimiento.caducidad;
      case 'transferencia':
        return TipoMovimiento.transferencia;
      default:
        throw ArgumentError('Tipo de movimiento no válido: $json');
    }
  }
}

/// Entidad de dominio para movimientos de stock
///
/// Representa un movimiento histórico de entrada/salida/ajuste de stock
class MovimientoStockEntity {
  /// Identificador único del movimiento
  final String id;

  /// ID del registro de stock (puede ser null si se eliminó)
  final String? stockVehiculoId;

  /// ID del vehículo
  final String vehiculoId;

  /// ID del producto
  final String productoId;

  /// Tipo de movimiento
  final TipoMovimiento tipoMovimiento;

  /// Cantidad del movimiento
  final int cantidad;

  /// Cantidad anterior al movimiento
  final int? cantidadAnterior;

  /// Cantidad nueva tras el movimiento
  final int? cantidadNueva;

  /// Motivo del movimiento
  final String? motivo;

  /// Referencia externa (nº servicio, pedido, etc.)
  final String? referencia;

  /// ID del vehículo destino (para transferencias)
  final String? vehiculoDestinoId;

  /// ID del usuario que realizó el movimiento
  final String? usuarioId;

  /// Fecha de creación del movimiento
  final DateTime createdAt;

  // Campos adicionales de JOINs

  /// Nombre del producto (de JOIN)
  final String? productoNombre;

  /// Matrícula del vehículo (de JOIN)
  final String? vehiculoMatricula;

  const MovimientoStockEntity({
    required this.id,
    this.stockVehiculoId,
    required this.vehiculoId,
    required this.productoId,
    required this.tipoMovimiento,
    required this.cantidad,
    this.cantidadAnterior,
    this.cantidadNueva,
    this.motivo,
    this.referencia,
    this.vehiculoDestinoId,
    this.usuarioId,
    required this.createdAt,
    this.productoNombre,
    this.vehiculoMatricula,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovimientoStockEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          stockVehiculoId == other.stockVehiculoId &&
          vehiculoId == other.vehiculoId &&
          productoId == other.productoId &&
          tipoMovimiento == other.tipoMovimiento &&
          cantidad == other.cantidad &&
          cantidadAnterior == other.cantidadAnterior &&
          cantidadNueva == other.cantidadNueva &&
          motivo == other.motivo &&
          referencia == other.referencia;

  @override
  int get hashCode =>
      id.hashCode ^
      stockVehiculoId.hashCode ^
      vehiculoId.hashCode ^
      productoId.hashCode ^
      tipoMovimiento.hashCode ^
      cantidad.hashCode ^
      cantidadAnterior.hashCode ^
      cantidadNueva.hashCode ^
      motivo.hashCode ^
      referencia.hashCode;

  @override
  String toString() =>
      'MovimientoStockEntity(id: $id, tipo: $tipoMovimiento, cantidad: $cantidad)';
}
