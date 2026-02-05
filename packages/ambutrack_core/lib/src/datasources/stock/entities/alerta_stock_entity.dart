/// Tipos de alerta de stock
enum TipoAlerta {
  /// Stock por debajo del mínimo
  stockBajo,

  /// Stock a cero
  sinStock,

  /// Caducidad próxima (8-30 días)
  caducidadProxima,

  /// Producto caducado
  caducado,
}

/// Extensión para convertir desde/hacia string
extension TipoAlertaExtension on TipoAlerta {
  /// Convierte el enum a string para la BD
  String toJson() {
    switch (this) {
      case TipoAlerta.stockBajo:
        return 'stock_bajo';
      case TipoAlerta.sinStock:
        return 'sin_stock';
      case TipoAlerta.caducidadProxima:
        return 'caducidad_proxima';
      case TipoAlerta.caducado:
        return 'caducado';
    }
  }

  /// Convierte desde string de la BD al enum
  static TipoAlerta fromJson(String json) {
    switch (json) {
      case 'stock_bajo':
        return TipoAlerta.stockBajo;
      case 'sin_stock':
        return TipoAlerta.sinStock;
      case 'caducidad_proxima':
        return TipoAlerta.caducidadProxima;
      case 'caducado':
        return TipoAlerta.caducado;
      default:
        throw ArgumentError('Tipo de alerta no válido: $json');
    }
  }
}

/// Niveles de alerta
enum NivelAlerta {
  /// Información
  info,

  /// Advertencia
  warning,

  /// Crítico
  critical,
}

/// Extensión para convertir desde/hacia string
extension NivelAlertaExtension on NivelAlerta {
  /// Convierte el enum a string para la BD
  String toJson() {
    switch (this) {
      case NivelAlerta.info:
        return 'info';
      case NivelAlerta.warning:
        return 'warning';
      case NivelAlerta.critical:
        return 'critical';
    }
  }

  /// Convierte desde string de la BD al enum
  static NivelAlerta fromJson(String json) {
    switch (json) {
      case 'info':
        return NivelAlerta.info;
      case 'warning':
        return NivelAlerta.warning;
      case 'critical':
        return NivelAlerta.critical;
      default:
        return NivelAlerta.warning;
    }
  }
}

/// Entidad de dominio para alertas de stock
///
/// Representa una alerta automática de stock bajo o caducidad
class AlertaStockEntity {
  /// Identificador único de la alerta
  final String id;

  /// ID del vehículo
  final String vehiculoId;

  /// ID del producto
  final String productoId;

  /// Tipo de alerta
  final TipoAlerta tipoAlerta;

  /// Mensaje de la alerta
  final String mensaje;

  /// Nivel de la alerta
  final NivelAlerta nivel;

  /// Fecha de caducidad (si aplica)
  final DateTime? fechaCaducidad;

  /// Cantidad actual (si aplica)
  final int? cantidadActual;

  /// Cantidad mínima (si aplica)
  final int? cantidadMinima;

  /// Indica si la alerta fue resuelta
  final bool resuelta;

  /// ID del usuario que resolvió la alerta
  final String? resueltaPor;

  /// Fecha de resolución
  final DateTime? resueltaAt;

  /// Fecha de creación de la alerta
  final DateTime createdAt;

  // Campos adicionales de JOINs

  /// Nombre del producto (de JOIN)
  final String? productoNombre;

  /// Matrícula del vehículo (de JOIN)
  final String? vehiculoMatricula;

  const AlertaStockEntity({
    required this.id,
    required this.vehiculoId,
    required this.productoId,
    required this.tipoAlerta,
    required this.mensaje,
    this.nivel = NivelAlerta.warning,
    this.fechaCaducidad,
    this.cantidadActual,
    this.cantidadMinima,
    this.resuelta = false,
    this.resueltaPor,
    this.resueltaAt,
    required this.createdAt,
    this.productoNombre,
    this.vehiculoMatricula,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertaStockEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vehiculoId == other.vehiculoId &&
          productoId == other.productoId &&
          tipoAlerta == other.tipoAlerta &&
          mensaje == other.mensaje &&
          nivel == other.nivel &&
          fechaCaducidad == other.fechaCaducidad &&
          cantidadActual == other.cantidadActual &&
          cantidadMinima == other.cantidadMinima &&
          resuelta == other.resuelta;

  @override
  int get hashCode =>
      id.hashCode ^
      vehiculoId.hashCode ^
      productoId.hashCode ^
      tipoAlerta.hashCode ^
      mensaje.hashCode ^
      nivel.hashCode ^
      fechaCaducidad.hashCode ^
      cantidadActual.hashCode ^
      cantidadMinima.hashCode ^
      resuelta.hashCode;

  @override
  String toString() =>
      'AlertaStockEntity(id: $id, tipo: $tipoAlerta, nivel: $nivel, resuelta: $resuelta)';
}
