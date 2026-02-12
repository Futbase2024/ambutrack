import 'package:equatable/equatable.dart';

/// Entidad de dominio para Vestuario del Personal
class VestuarioEntity extends Equatable {
  const VestuarioEntity({
    required this.id,
    required this.personalId,
    required this.prenda,
    required this.talla,
    required this.fechaEntrega,
    this.fechaDevolucion,
    this.cantidad,
    this.marca,
    this.color,
    this.estado,
    this.observaciones,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String personalId;
  final String prenda;
  final String talla;
  final DateTime fechaEntrega;
  final DateTime? fechaDevolucion;
  final int? cantidad;
  final String? marca;
  final String? color;
  final String? estado;
  final String? observaciones;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Verifica si el vestuario está actualmente asignado
  bool get estaAsignado => fechaDevolucion == null && activo;

  /// Verifica si el vestuario fue devuelto
  bool get fueDevuelto => fechaDevolucion != null;

  @override
  List<Object?> get props => <Object?>[
        id,
        personalId,
        prenda,
        talla,
        fechaEntrega,
        fechaDevolucion,
        cantidad,
        marca,
        color,
        estado,
        observaciones,
        activo,
        createdAt,
        updatedAt,
      ];
}
