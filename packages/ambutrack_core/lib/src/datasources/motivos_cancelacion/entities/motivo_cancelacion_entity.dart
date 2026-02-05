import '../../../core/base_entity.dart';

/// Entidad de dominio para motivos de cancelación de servicios
///
/// Representa un motivo por el cual un servicio médico puede ser cancelado.
/// Extiende [BaseEntity] para incluir campos comunes (id, createdAt, updatedAt).
class MotivoCancelacionEntity extends BaseEntity {
  const MotivoCancelacionEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    this.descripcion,
    required this.activo,
  });

  /// Nombre del motivo de cancelación
  final String nombre;

  /// Descripción detallada del motivo (opcional)
  final String? descripcion;

  /// Estado activo/inactivo del motivo
  final bool activo;

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        updatedAt,
        nombre,
        descripcion,
        activo,
      ];

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
    };
  }

  @override
  MotivoCancelacionEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    String? descripcion,
    bool? activo,
  }) {
    return MotivoCancelacionEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
    );
  }
}
