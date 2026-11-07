import 'package:equatable/equatable.dart';

/// Tipos de movimiento de stock
enum TipoMovimientoStock {
  /// Llegada de proveedor a Base Central
  entradaCompra('ENTRADA_COMPRA', 'Entrada Compra'),

  /// Transferencia desde Base a Vehículo
  transferenciaAVehiculo('TRANSFERENCIA_A_VEHICULO', 'Transferencia a Vehículo'),

  /// Devolución desde Vehículo a Base
  transferenciaDeVehiculo('TRANSFERENCIA_DE_VEHICULO', 'Devolución de Vehículo'),

  /// Transferencia entre Vehículos
  transferenciaEntreVehiculos('TRANSFERENCIA_ENTRE_VEHICULOS', 'Transferencia entre Vehículos'),

  /// Consumo en servicio real
  consumoServicio('CONSUMO_SERVICIO', 'Consumo en Servicio'),

  /// Ajuste manual de inventario
  ajusteInventario('AJUSTE_INVENTARIO', 'Ajuste de Inventario'),

  /// Baja por caducidad
  bajaCaducidad('BAJA_CADUCIDAD', 'Baja por Caducidad'),

  /// Baja por deterioro
  bajaDeterioro('BAJA_DETERIORO', 'Baja por Deterioro'),

  /// Devolución a proveedor
  devolucionProveedor('DEVOLUCION_PROVEEDOR', 'Devolución a Proveedor');

  const TipoMovimientoStock(this.code, this.label);

  final String code;
  final String label;

  static TipoMovimientoStock fromCode(String code) {
    return TipoMovimientoStock.values.firstWhere(
      (tipo) => tipo.code == code,
      orElse: () => TipoMovimientoStock.ajusteInventario,
    );
  }

  /// Retorna true si es un movimiento de entrada
  bool get esEntrada =>
      this == TipoMovimientoStock.entradaCompra ||
      this == TipoMovimientoStock.transferenciaDeVehiculo ||
      this == TipoMovimientoStock.ajusteInventario;

  /// Retorna true si es un movimiento de salida
  bool get esSalida =>
      this == TipoMovimientoStock.transferenciaAVehiculo ||
      this == TipoMovimientoStock.consumoServicio ||
      this == TipoMovimientoStock.bajaCaducidad ||
      this == TipoMovimientoStock.bajaDeterioro ||
      this == TipoMovimientoStock.devolucionProveedor;

  /// Retorna true si es una transferencia
  bool get esTransferencia =>
      this == TipoMovimientoStock.transferenciaAVehiculo ||
      this == TipoMovimientoStock.transferenciaDeVehiculo ||
      this == TipoMovimientoStock.transferenciaEntreVehiculos;
}

/// Entidad de Movimiento de Stock
///
/// Representa la trazabilidad completa de todos los movimientos de stock.
/// Soporta movimientos entre almacenes (Base Central y Vehículos).
class MovimientoStockEntity extends Equatable {
  const MovimientoStockEntity({
    required this.id,
    required this.tipo,
    required this.idProducto,
    required this.cantidad,
    this.idAlmacenOrigen,
    this.idAlmacenDestino,
    this.cantidadAnterior,
    this.cantidadNueva,
    this.lote,
    this.numeroSerie,
    this.idServicio,
    this.motivo,
    this.referencia,
    this.usuarioId,
    this.observaciones,
    this.createdAt,
  });

  /// ID único del movimiento
  final String id;

  /// Tipo de movimiento
  final TipoMovimientoStock tipo;

  /// ID del producto
  final String idProducto;

  /// ID del almacén de origen (null si es entrada de proveedor)
  final String? idAlmacenOrigen;

  /// ID del almacén de destino (null si es consumo/baja)
  final String? idAlmacenDestino;

  /// Cantidad del movimiento
  final double cantidad;

  /// Cantidad anterior al movimiento
  final double? cantidadAnterior;

  /// Cantidad nueva tras el movimiento
  final double? cantidadNueva;

  /// Lote del producto (para MEDICACION)
  final String? lote;

  /// Número de serie (para ELECTROMEDICINA)
  final String? numeroSerie;

  /// ID del servicio (solo si tipo = CONSUMO_SERVICIO)
  final String? idServicio;

  /// Motivo del movimiento
  final String? motivo;

  /// Referencia externa (nº factura, albarán, etc.)
  final String? referencia;

  /// ID del usuario que realizó el movimiento
  final String? usuarioId;

  /// Observaciones adicionales
  final String? observaciones;

  /// Fecha de creación del movimiento
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        tipo,
        idProducto,
        idAlmacenOrigen,
        idAlmacenDestino,
        cantidad,
        cantidadAnterior,
        cantidadNueva,
        lote,
        numeroSerie,
        idServicio,
        motivo,
        referencia,
        usuarioId,
        observaciones,
        createdAt,
      ];

  MovimientoStockEntity copyWith({
    String? id,
    TipoMovimientoStock? tipo,
    String? idProducto,
    String? idAlmacenOrigen,
    String? idAlmacenDestino,
    double? cantidad,
    double? cantidadAnterior,
    double? cantidadNueva,
    String? lote,
    String? numeroSerie,
    String? idServicio,
    String? motivo,
    String? referencia,
    String? usuarioId,
    String? observaciones,
    DateTime? createdAt,
  }) {
    return MovimientoStockEntity(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      idProducto: idProducto ?? this.idProducto,
      idAlmacenOrigen: idAlmacenOrigen ?? this.idAlmacenOrigen,
      idAlmacenDestino: idAlmacenDestino ?? this.idAlmacenDestino,
      cantidad: cantidad ?? this.cantidad,
      cantidadAnterior: cantidadAnterior ?? this.cantidadAnterior,
      cantidadNueva: cantidadNueva ?? this.cantidadNueva,
      lote: lote ?? this.lote,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      idServicio: idServicio ?? this.idServicio,
      motivo: motivo ?? this.motivo,
      referencia: referencia ?? this.referencia,
      usuarioId: usuarioId ?? this.usuarioId,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
