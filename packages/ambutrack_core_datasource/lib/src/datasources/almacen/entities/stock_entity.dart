import '../../../core/base_entity.dart';

/// Entidad de Stock unificada
///
/// Representa la cantidad de un producto en un almacén específico.
/// Unifica el concepto de stock de Base Central y Vehículos.
class StockEntity extends BaseEntity {
  const StockEntity({
    required super.id,
    required this.idAlmacen,
    required this.idProducto,
    required this.cantidadActual,
    this.cantidadMinima = 0,
    this.cantidadMaxima,
    this.cantidadReservada = 0,
    this.lote,
    this.fechaCaducidad,
    this.numeroSerie,
    this.ubicacionFisica,
    this.precioUnitario,
    this.precioTotal,
    this.moneda = 'EUR',
    this.proveedorId,
    this.numeroFactura,
    this.fechaEntrada,
    this.observaciones,
    this.activo = true,
    required super.createdAt,
    required super.updatedAt,
    this.updatedBy,
  });

  /// ID del almacén (Base Central o Vehículo)
  final String idAlmacen;

  /// ID del producto
  final String idProducto;

  /// Cantidad actual disponible
  final double cantidadActual;

  /// Cantidad mínima (alerta de reposición)
  final double cantidadMinima;

  /// Cantidad máxima permitida
  final double? cantidadMaxima;

  /// Cantidad reservada para transferencias pendientes
  final double cantidadReservada;

  /// Lote (obligatorio para MEDICACION)
  final String? lote;

  /// Fecha de caducidad (para MEDICACION y algunos materiales)
  final DateTime? fechaCaducidad;

  /// Número de serie (obligatorio para ELECTROMEDICINA)
  final String? numeroSerie;

  /// Ubicación física dentro del almacén/vehículo
  /// Ej: "Estante A3" en Base Central o "Maletín 1" en Vehículo
  final String? ubicacionFisica;

  /// Precio unitario del producto
  final double? precioUnitario;

  /// Precio total (calculado automáticamente: precioUnitario * cantidadActual)
  final double? precioTotal;

  /// Moneda (por defecto EUR)
  final String moneda;

  /// ID del proveedor
  final String? proveedorId;

  /// Número de factura de compra
  final String? numeroFactura;

  /// Fecha de entrada al almacén
  final DateTime? fechaEntrada;

  /// Observaciones adicionales
  final String? observaciones;

  /// Estado activo/inactivo
  final bool activo;

  /// ID del usuario que actualizó
  final String? updatedBy;

  /// Retorna true si la cantidad está por debajo del mínimo
  bool get bajoCantidadMinima => cantidadActual < cantidadMinima;

  /// Retorna true si tiene lote asignado
  bool get tieneLote => lote != null && lote!.isNotEmpty;

  /// Retorna true si tiene número de serie
  bool get tieneNumeroSerie => numeroSerie != null && numeroSerie!.isNotEmpty;

  /// Retorna true si está próximo a caducar (30 días)
  bool get proximoACaducar {
    if (fechaCaducidad == null) return false;
    final diasRestantes = fechaCaducidad!.difference(DateTime.now()).inDays;
    return diasRestantes <= 30 && diasRestantes >= 0;
  }

  /// Retorna true si está caducado
  bool get caducado {
    if (fechaCaducidad == null) return false;
    return fechaCaducidad!.isBefore(DateTime.now());
  }

  /// Cantidad disponible real (actual - reservada)
  double get cantidadDisponible => cantidadActual - cantidadReservada;

  @override
  List<Object?> get props => [
        id,
        idAlmacen,
        idProducto,
        cantidadActual,
        cantidadMinima,
        cantidadMaxima,
        cantidadReservada,
        lote,
        fechaCaducidad,
        numeroSerie,
        ubicacionFisica,
        precioUnitario,
        precioTotal,
        moneda,
        proveedorId,
        numeroFactura,
        fechaEntrada,
        observaciones,
        activo,
        createdAt,
        updatedAt,
        updatedBy,
      ];

  @override
  StockEntity copyWith({
    String? id,
    String? idAlmacen,
    String? idProducto,
    double? cantidadActual,
    double? cantidadMinima,
    double? cantidadMaxima,
    double? cantidadReservada,
    String? lote,
    DateTime? fechaCaducidad,
    String? numeroSerie,
    String? ubicacionFisica,
    double? precioUnitario,
    double? precioTotal,
    String? moneda,
    String? proveedorId,
    String? numeroFactura,
    DateTime? fechaEntrada,
    String? observaciones,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return StockEntity(
      id: id ?? this.id,
      idAlmacen: idAlmacen ?? this.idAlmacen,
      idProducto: idProducto ?? this.idProducto,
      cantidadActual: cantidadActual ?? this.cantidadActual,
      cantidadMinima: cantidadMinima ?? this.cantidadMinima,
      cantidadMaxima: cantidadMaxima ?? this.cantidadMaxima,
      cantidadReservada: cantidadReservada ?? this.cantidadReservada,
      lote: lote ?? this.lote,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      ubicacionFisica: ubicacionFisica ?? this.ubicacionFisica,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      precioTotal: precioTotal ?? this.precioTotal,
      moneda: moneda ?? this.moneda,
      proveedorId: proveedorId ?? this.proveedorId,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      fechaEntrada: fechaEntrada ?? this.fechaEntrada,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_almacen': idAlmacen,
      'id_producto': idProducto,
      'cantidad_actual': cantidadActual,
      'cantidad_minima': cantidadMinima,
      'cantidad_maxima': cantidadMaxima,
      'cantidad_reservada': cantidadReservada,
      'lote': lote,
      'fecha_caducidad': fechaCaducidad?.toIso8601String(),
      'numero_serie': numeroSerie,
      'ubicacion_fisica': ubicacionFisica,
      'precio_unitario': precioUnitario,
      'precio_total': precioTotal,
      'moneda': moneda,
      'proveedor_id': proveedorId,
      'numero_factura': numeroFactura,
      'fecha_entrada': fechaEntrada?.toIso8601String(),
      'observaciones': observaciones,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,
    };
  }
}
