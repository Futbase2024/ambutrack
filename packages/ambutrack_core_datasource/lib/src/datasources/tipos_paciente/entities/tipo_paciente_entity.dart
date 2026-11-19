import '../../../core/base_entity.dart';

/// Entidad de dominio para un tipo de paciente
///
/// Representa una categoría o clasificación de pacientes
/// (ej: "Adulto", "Pediátrico", "Geriátrico", etc.)
class TipoPacienteEntity extends BaseEntity {
  const TipoPacienteEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    this.descripcion,
    required this.activo,
  });

  /// Nombre del tipo de paciente
  final String nombre;

  /// Descripción detallada (opcional)
  final String? descripcion;

  /// Indica si el tipo de paciente está activo
  final bool activo;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
    };
  }

  @override
  TipoPacienteEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    String? descripcion,
    bool? activo,
  }) {
    return TipoPacienteEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        nombre,
        descripcion,
        activo,
      ];
}
