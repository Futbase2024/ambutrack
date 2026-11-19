import 'package:equatable/equatable.dart';

/// Entidad de dominio para Entrada de Almacén
///
/// Representa el encabezado de una entrada/recepción de material al almacén
class EntradaAlmacenEntity extends Equatable {
  const EntradaAlmacenEntity({
    required this.id,
    required this.numeroEntrada,
    required this.tipo,
    required this.fecha,
    this.proveedorId,
    this.numeroFactura,
    this.numeroAlbaran,
    this.observaciones,
    required this.total,
    this.moneda = 'EUR',
    required this.registradaPor,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String numeroEntrada;
  final String tipo; // 'compra', 'devolucion', 'ajuste'
  final DateTime fecha;
  final String? proveedorId;
  final String? numeroFactura;
  final String? numeroAlbaran;
  final String? observaciones;
  final double total;
  final String moneda;
  final String registradaPor;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        numeroEntrada,
        tipo,
        fecha,
        proveedorId,
        numeroFactura,
        numeroAlbaran,
        observaciones,
        total,
        moneda,
        registradaPor,
        activo,
        createdAt,
        updatedAt,
      ];

  EntradaAlmacenEntity copyWith({
    String? id,
    String? numeroEntrada,
    String? tipo,
    DateTime? fecha,
    String? proveedorId,
    String? numeroFactura,
    String? numeroAlbaran,
    String? observaciones,
    double? total,
    String? moneda,
    String? registradaPor,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EntradaAlmacenEntity(
      id: id ?? this.id,
      numeroEntrada: numeroEntrada ?? this.numeroEntrada,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      proveedorId: proveedorId ?? this.proveedorId,
      numeroFactura: numeroFactura ?? this.numeroFactura,
      numeroAlbaran: numeroAlbaran ?? this.numeroAlbaran,
      observaciones: observaciones ?? this.observaciones,
      total: total ?? this.total,
      moneda: moneda ?? this.moneda,
      registradaPor: registradaPor ?? this.registradaPor,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
