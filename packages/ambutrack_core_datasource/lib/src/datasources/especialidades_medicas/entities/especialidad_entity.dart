import '../../../core/base_entity.dart';

/// Entidad de dominio para Especialidades Médicas
class EspecialidadEntity extends BaseEntity {
  const EspecialidadEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    this.descripcion,
    required this.requiereCertificacion,
    required this.tipoEspecialidad,
    required this.activo,
  });

  final String nombre;
  final String? descripcion;
  final bool requiereCertificacion;
  final String tipoEspecialidad;
  final bool activo;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      'requiere_certificacion': requiereCertificacion,
      'tipo_especialidad': tipoEspecialidad,
      'activo': activo,
    };
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        updatedAt,
        nombre,
        descripcion,
        requiereCertificacion,
        tipoEspecialidad,
        activo,
      ];

  @override
  EspecialidadEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    String? descripcion,
    bool? requiereCertificacion,
    String? tipoEspecialidad,
    bool? activo,
  }) {
    return EspecialidadEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      requiereCertificacion: requiereCertificacion ?? this.requiereCertificacion,
      tipoEspecialidad: tipoEspecialidad ?? this.tipoEspecialidad,
      activo: activo ?? this.activo,
    );
  }
}
