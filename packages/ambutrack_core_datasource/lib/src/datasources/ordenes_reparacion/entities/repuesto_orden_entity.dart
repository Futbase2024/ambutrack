import 'package:equatable/equatable.dart';

import 'orden_reparacion_enums.dart';

/// Entity: Repuesto asociado a una orden de reparación
///
/// `precioTotal` es columna generada en BD (cantidad × precio unitario).
/// `proveedorNombre` es de solo lectura (join con tproveedores_taller).
class RepuestoOrdenEntity extends Equatable {
  const RepuestoOrdenEntity({
    required this.id,
    required this.ordenId,
    this.proveedorId,
    required this.descripcion,
    this.referencia,
    this.cantidad = 1,
    required this.precioUnitario,
    this.precioTotal = 0,
    this.estado = EstadoRepuesto.solicitado,
    this.fechaPedido,
    this.fechaRecibido,
    this.observaciones,
    required this.createdAt,
    this.proveedorNombre,
  });

  final String id;
  final String ordenId;
  final String? proveedorId;
  final String descripcion;
  final String? referencia;
  final int cantidad;
  final double precioUnitario;
  final double precioTotal;
  final EstadoRepuesto estado;
  final DateTime? fechaPedido;
  final DateTime? fechaRecibido;
  final String? observaciones;
  final DateTime createdAt;

  // Solo lectura (join)
  final String? proveedorNombre;

  /// Importe calculado en cliente (útil antes de persistir)
  double get importeCalculado => cantidad * precioUnitario;

  RepuestoOrdenEntity copyWith({
    String? proveedorId,
    String? descripcion,
    String? referencia,
    int? cantidad,
    double? precioUnitario,
    EstadoRepuesto? estado,
    DateTime? fechaPedido,
    DateTime? fechaRecibido,
    String? observaciones,
  }) {
    return RepuestoOrdenEntity(
      id: id,
      ordenId: ordenId,
      proveedorId: proveedorId ?? this.proveedorId,
      descripcion: descripcion ?? this.descripcion,
      referencia: referencia ?? this.referencia,
      cantidad: cantidad ?? this.cantidad,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      precioTotal: precioTotal,
      estado: estado ?? this.estado,
      fechaPedido: fechaPedido ?? this.fechaPedido,
      fechaRecibido: fechaRecibido ?? this.fechaRecibido,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt,
      proveedorNombre: proveedorNombre,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        ordenId,
        proveedorId,
        descripcion,
        referencia,
        cantidad,
        precioUnitario,
        precioTotal,
        estado,
        fechaPedido,
        fechaRecibido,
        observaciones,
        proveedorNombre,
      ];
}
