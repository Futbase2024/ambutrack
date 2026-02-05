import 'package:equatable/equatable.dart';

/// Entidad de dominio para Stock de Almacén
///
/// Representa el inventario centralizado del almacén general
class StockAlmacenEntity extends Equatable {
  const StockAlmacenEntity({
    required this.id,
    required this.productoId,
    required this.cantidadDisponible,
    this.cantidadReservada = 0,
    this.cantidadMinima = 0,
    this.lote,
    this.fechaCaducidad,
    required this.fechaEntrada,
    this.ubicacionAlmacen,
    this.zona,
    this.proveedorId,
    this.numeroFactura,
    this.precioUnitario,
    this.precioTotal,
    this.moneda = 'EUR',
    this.observaciones,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  final String id;
  final String productoId;
  final int cantidadDisponible;
  final int cantidadReservada;
  final int cantidadMinima;
  final String? lote;
  final DateTime? fechaCaducidad;
  final DateTime fechaEntrada;
  final String? ubicacionAlmacen;
  final String? zona;
  final String? proveedorId;
  final String? numeroFactura;
  final double? precioUnitario;
  final double? precioTotal;
  final String moneda;
  final String? observaciones;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  @override
  List<Object?> get props => [
        id,
        productoId,
        cantidadDisponible,
        cantidadReservada,
        cantidadMinima,
        lote,
        fechaCaducidad,
        fechaEntrada,
        ubicacionAlmacen,
        zona,
        proveedorId,
        numeroFactura,
        precioUnitario,
        precioTotal,
        moneda,
        observaciones,
        activo,
        createdAt,
        updatedAt,
        updatedBy,
      ];

  StockAlmacenEntity copyWith({
    String? id,
    String? productoId,
    int? cantidadDisponible,
    int? cantidadReservada,
    int? cantidadMinima,
    String? lote,
    DateTime? fechaCaducidad,
    DateTime? fechaEntrada,
    String? ubicacionAlmacen,
    String? zona,
    String? proveedorId,
    String? numeroFactura,
    double? precioUnitario,
    double? precioTotal,
    String? moneda,
    String? observaciones,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return StockAlmacenEntity(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      cantidadDisponible: cantidadDisponible ?? this.cantidadDisponible,
      cantidadReservada: cantidadReservada ?? this.cantidadReservada,
      cantidadMinima: cantidadMinima ?? this.cantidadMinima,
      lote: lote ?? this.lote,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      fechaEntrada: fechaEntrada ?? this.fechaEntrada,
      ubicacionAlmacen: ubicacionAlmacen ?? this.ubicacionAlmacen,
      zona: zona ?? this.zona,
      proveedorId: proveedorId ?? this.proveedorId,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      precioTotal: precioTotal ?? this.precioTotal,
      moneda: moneda ?? this.moneda,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
