import 'package:equatable/equatable.dart';

/// Entidad de dominio para Detalle de Entrada de Almacén
///
/// Representa una línea individual de un recibo/entrada de almacén
class DetalleEntradaEntity extends Equatable {
  const DetalleEntradaEntity({
    required this.id,
    required this.entradaId,
    required this.productoId,
    required this.cantidad,
    this.lote,
    this.fechaCaducidad,
    required this.precioUnitario,
    required this.subtotal,
    this.descuento = 0,
    this.ubicacionAsignada,
    this.zona,
    this.observaciones,
    required this.createdAt,
  });

  final String id;
  final String entradaId;
  final String productoId;
  final int cantidad;
  final String? lote;
  final DateTime? fechaCaducidad;
  final double precioUnitario;
  final double subtotal;
  final double descuento;
  final String? ubicacionAsignada;
  final String? zona;
  final String? observaciones;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        entradaId,
        productoId,
        cantidad,
        lote,
        fechaCaducidad,
        precioUnitario,
        subtotal,
        descuento,
        ubicacionAsignada,
        zona,
        observaciones,
        createdAt,
      ];

  DetalleEntradaEntity copyWith({
    String? id,
    String? entradaId,
    String? productoId,
    int? cantidad,
    String? lote,
    DateTime? fechaCaducidad,
    double? precioUnitario,
    double? subtotal,
    double? descuento,
    String? ubicacionAsignada,
    String? zona,
    String? observaciones,
    DateTime? createdAt,
  }) {
    return DetalleEntradaEntity(
      id: id ?? this.id,
      entradaId: entradaId ?? this.entradaId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      lote: lote ?? this.lote,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      subtotal: subtotal ?? this.subtotal,
      descuento: descuento ?? this.descuento,
      ubicacionAsignada: ubicacionAsignada ?? this.ubicacionAsignada,
      zona: zona ?? this.zona,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
