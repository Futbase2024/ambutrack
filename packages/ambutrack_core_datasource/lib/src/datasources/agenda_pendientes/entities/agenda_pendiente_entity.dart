import '../../../core/base_entity.dart';

/// Entidad de dominio para agenda de pendientes
///
/// Representa un servicio pendiente que aún no ha sido grabado
/// y necesita ser anotado para recordar sus detalles.
class AgendaPendienteEntity extends BaseEntity {
  const AgendaPendienteEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.empresaId,
    required this.nombreApellidos,
    this.domicilio,
    this.localidad,
    required this.fecha,
    required this.descripcion,
    required this.completado,
    this.createdBy,
  });

  /// ID de la empresa a la que pertenece el pendiente
  final String empresaId;

  /// Nombre y apellidos del paciente/contacto (obligatorio)
  final String nombreApellidos;

  /// Domicilio (opcional)
  final String? domicilio;

  /// Localidad (opcional)
  final String? localidad;

  /// Fecha del servicio programado (obligatorio)
  final DateTime fecha;

  /// Descripción del pendiente (obligatorio)
  final String descripcion;

  /// Indica si el pendiente ya fue completado
  final bool completado;

  /// ID del usuario que creó el pendiente
  final String? createdBy;

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        updatedAt,
        empresaId,
        nombreApellidos,
        domicilio,
        localidad,
        fecha,
        descripcion,
        completado,
        createdBy,
      ];

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'empresa_id': empresaId,
      'nombre_apellidos': nombreApellidos,
      'domicilio': domicilio,
      'localidad': localidad,
      'fecha': fecha.toIso8601String().split('T')[0],
      'descripcion': descripcion,
      'completado': completado,
      'created_by': createdBy,
    };
  }

  @override
  AgendaPendienteEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? empresaId,
    String? nombreApellidos,
    String? domicilio,
    String? localidad,
    DateTime? fecha,
    String? descripcion,
    bool? completado,
    String? createdBy,
  }) {
    return AgendaPendienteEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      empresaId: empresaId ?? this.empresaId,
      nombreApellidos: nombreApellidos ?? this.nombreApellidos,
      domicilio: domicilio ?? this.domicilio,
      localidad: localidad ?? this.localidad,
      fecha: fecha ?? this.fecha,
      descripcion: descripcion ?? this.descripcion,
      completado: completado ?? this.completado,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
