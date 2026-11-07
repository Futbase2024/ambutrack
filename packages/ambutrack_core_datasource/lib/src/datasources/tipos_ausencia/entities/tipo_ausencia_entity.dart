import 'package:equatable/equatable.dart';

/// Entidad de dominio para Tipo de Ausencia
class TipoAusenciaEntity extends Equatable {
  const TipoAusenciaEntity({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.requiereAprobacion,
    required this.requiereDocumento,
    required this.color,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String nombre;
  final String? descripcion;
  final bool requiereAprobacion;
  final bool requiereDocumento;
  final String color;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        requiereAprobacion,
        requiereDocumento,
        color,
        activo,
        createdAt,
        updatedAt,
      ];

  TipoAusenciaEntity copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    bool? requiereAprobacion,
    bool? requiereDocumento,
    String? color,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TipoAusenciaEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      requiereAprobacion: requiereAprobacion ?? this.requiereAprobacion,
      requiereDocumento: requiereDocumento ?? this.requiereDocumento,
      color: color ?? this.color,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
