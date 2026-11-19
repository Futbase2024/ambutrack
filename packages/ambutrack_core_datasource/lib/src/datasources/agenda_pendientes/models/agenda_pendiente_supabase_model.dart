import '../entities/agenda_pendiente_entity.dart';

/// Modelo de datos para Supabase de agenda de pendientes
///
/// Maneja la serialización/deserialización entre JSON de Supabase
/// y [AgendaPendienteEntity].
/// Utiliza snake_case para los campos de la base de datos.
class AgendaPendienteSupabaseModel {
  const AgendaPendienteSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.empresaId,
    required this.nombreApellidos,
    this.domicilio,
    this.localidad,
    required this.fecha,
    required this.descripcion,
    required this.completado,
    this.createdBy,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String empresaId;
  final String nombreApellidos;
  final String? domicilio;
  final String? localidad;
  final DateTime fecha;
  final String descripcion;
  final bool completado;
  final String? createdBy;

  /// Crea un modelo desde JSON de Supabase
  factory AgendaPendienteSupabaseModel.fromJson(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();

    return AgendaPendienteSupabaseModel(
      id: json['id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : now,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : now,
      empresaId: json['empresa_id'] as String? ?? '',
      nombreApellidos: json['nombre_apellidos'] as String? ?? '',
      domicilio: json['domicilio'] as String?,
      localidad: json['localidad'] as String?,
      fecha: json['fecha'] != null
          ? DateTime.parse('${json['fecha'] as String}T00:00:00.000')
          : now,
      descripcion: json['descripcion'] as String? ?? '',
      completado: json['completado'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
    );
  }

  /// Convierte el modelo a JSON para Supabase
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'empresa_id': empresaId,
      'nombre_apellidos': nombreApellidos,
      if (domicilio != null) 'domicilio': domicilio,
      if (localidad != null) 'localidad': localidad,
      'fecha': fecha.toIso8601String().split('T')[0],
      'descripcion': descripcion,
      'completado': completado,
      'created_by': createdBy,
    };
  }

  /// Convierte el modelo a entidad de dominio
  AgendaPendienteEntity toEntity() {
    return AgendaPendienteEntity(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      empresaId: empresaId,
      nombreApellidos: nombreApellidos,
      domicilio: domicilio,
      localidad: localidad,
      fecha: fecha,
      descripcion: descripcion,
      completado: completado,
      createdBy: createdBy,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory AgendaPendienteSupabaseModel.fromEntity(
    AgendaPendienteEntity entity,
  ) {
    return AgendaPendienteSupabaseModel(
      id: entity.id,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      empresaId: entity.empresaId,
      nombreApellidos: entity.nombreApellidos,
      domicilio: entity.domicilio,
      localidad: entity.localidad,
      fecha: entity.fecha,
      descripcion: entity.descripcion,
      completado: entity.completado,
      createdBy: entity.createdBy,
    );
  }
}
