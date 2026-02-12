import 'package:equatable/equatable.dart';

/// Entidad de dominio para Transferencia de Stock
///
/// Representa una transferencia de material entre almacén y vehículos
class TransferenciaEntity extends Equatable {
  const TransferenciaEntity({
    required this.id,
    required this.numeroTransferencia,
    required this.tipo,
    required this.origenTipo,
    this.origenId,
    required this.destinoTipo,
    this.destinoId,
    required this.productoId,
    required this.cantidad,
    this.lote,
    required this.fecha,
    this.motivoTransferencia,
    this.observaciones,
    required this.registradaPor,
    this.autorizadaPor,
    this.urgente = false,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String numeroTransferencia;
  final String tipo; // 'asignacion', 'devolucion', 'ajuste'
  final String origenTipo; // 'almacen', 'vehiculo'
  final String? origenId; // vehiculo_id si origen es vehiculo
  final String destinoTipo; // 'almacen', 'vehiculo'
  final String? destinoId; // vehiculo_id si destino es vehiculo
  final String productoId;
  final int cantidad;
  final String? lote;
  final DateTime fecha;
  final String? motivoTransferencia;
  final String? observaciones;
  final String registradaPor;
  final String? autorizadaPor;
  final bool urgente;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        numeroTransferencia,
        tipo,
        origenTipo,
        origenId,
        destinoTipo,
        destinoId,
        productoId,
        cantidad,
        lote,
        fecha,
        motivoTransferencia,
        observaciones,
        registradaPor,
        autorizadaPor,
        urgente,
        activo,
        createdAt,
        updatedAt,
      ];

  TransferenciaEntity copyWith({
    String? id,
    String? numeroTransferencia,
    String? tipo,
    String? origenTipo,
    String? origenId,
    String? destinoTipo,
    String? destinoId,
    String? productoId,
    int? cantidad,
    String? lote,
    DateTime? fecha,
    String? motivoTransferencia,
    String? observaciones,
    String? registradaPor,
    String? autorizadaPor,
    bool? urgente,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransferenciaEntity(
      id: id ?? this.id,
      numeroTransferencia: numeroTransferencia ?? this.numeroTransferencia,
      tipo: tipo ?? this.tipo,
      origenTipo: origenTipo ?? this.origenTipo,
      origenId: origenId ?? this.origenId,
      destinoTipo: destinoTipo ?? this.destinoTipo,
      destinoId: destinoId ?? this.destinoId,
      productoId: productoId ?? this.productoId,
      cantidad: cantidad ?? this.cantidad,
      lote: lote ?? this.lote,
      fecha: fecha ?? this.fecha,
      motivoTransferencia: motivoTransferencia ?? this.motivoTransferencia,
      observaciones: observaciones ?? this.observaciones,
      registradaPor: registradaPor ?? this.registradaPor,
      autorizadaPor: autorizadaPor ?? this.autorizadaPor,
      urgente: urgente ?? this.urgente,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
