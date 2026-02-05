import '../../../core/base_entity.dart';

/// Entidad de dominio para un facultativo médico
///
/// Representa a un profesional médico con su información personal,
/// especialidad y datos de contacto.
class FacultativoEntity extends BaseEntity {
  const FacultativoEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    required this.apellidos,
    this.numColegiado,
    this.especialidadId,
    this.especialidadNombre,
    this.telefono,
    this.email,
    required this.activo,
  });

  /// Nombre del facultativo
  final String nombre;

  /// Apellidos del facultativo
  final String apellidos;

  /// Número de colegiado (opcional)
  final String? numColegiado;

  /// ID de la especialidad médica (FK a tespecialidades)
  final String? especialidadId;

  /// Nombre de la especialidad (campo calculado desde JOIN)
  final String? especialidadNombre;

  /// Teléfono de contacto (opcional)
  final String? telefono;

  /// Email de contacto (opcional)
  final String? email;

  /// Indica si el facultativo está activo
  final bool activo;

  /// Nombre completo del facultativo (getter calculado)
  String get nombreCompleto => '$nombre $apellidos';

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      'apellidos': apellidos,
      'num_colegiado': numColegiado,
      'especialidad_id': especialidadId,
      'especialidad_nombre': especialidadNombre,
      'telefono': telefono,
      'email': email,
      'activo': activo,
    };
  }

  @override
  FacultativoEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    String? apellidos,
    String? numColegiado,
    String? especialidadId,
    String? especialidadNombre,
    String? telefono,
    String? email,
    bool? activo,
  }) {
    return FacultativoEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      numColegiado: numColegiado ?? this.numColegiado,
      especialidadId: especialidadId ?? this.especialidadId,
      especialidadNombre: especialidadNombre ?? this.especialidadNombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      activo: activo ?? this.activo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        updatedAt,
        nombre,
        apellidos,
        numColegiado,
        especialidadId,
        especialidadNombre,
        telefono,
        email,
        activo,
      ];
}
