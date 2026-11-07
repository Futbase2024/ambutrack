import '../entities/itv_revision_entity.dart';

/// Modelo de Supabase para ItvRevision
/// Mapea entre snake_case (Supabase) y camelCase (Dart)
class ItvRevisionSupabaseModel {
  const ItvRevisionSupabaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.vehiculoId,
    required this.fecha,
    required this.tipo,
    required this.resultado,
    required this.kmVehiculo,
    this.fechaVencimiento,
    this.observaciones,
    this.taller,
    this.numeroDocumento,
    this.costoTotal = 0.0,
    this.estado = EstadoItvRevision.pendiente,
    this.empresaId,
    this.createdBy,
    this.updatedBy,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String vehiculoId;
  final DateTime fecha;
  final TipoItvRevision tipo;
  final ResultadoItvRevision resultado;
  final double kmVehiculo;
  final DateTime? fechaVencimiento;
  final String? observaciones;
  final String? taller;
  final String? numeroDocumento;
  final double costoTotal;
  final EstadoItvRevision estado;
  final String? empresaId;
  final String? createdBy;
  final String? updatedBy;

  /// Convierte desde JSON de Supabase (snake_case) a Model
  factory ItvRevisionSupabaseModel.fromJson(Map<String, dynamic> json) {
    return ItvRevisionSupabaseModel(
      id: json['id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      vehiculoId: json['vehiculo_id'] as String? ?? '',
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now(),
      tipo: TipoItvRevision.fromString(json['tipo'] as String?),
      resultado: ResultadoItvRevision.fromString(json['resultado'] as String?),
      kmVehiculo: (json['km_vehiculo'] as num?)?.toDouble() ?? 0.0,
      fechaVencimiento: json['fecha_vencimiento'] != null
          ? DateTime.parse(json['fecha_vencimiento'] as String)
          : null,
      observaciones: json['observaciones'] as String?,
      taller: json['taller'] as String?,
      numeroDocumento: json['numero_documento'] as String?,
      costoTotal: (json['costo_total'] as num?)?.toDouble() ?? 0.0,
      estado: EstadoItvRevision.fromString(json['estado'] as String?),
      empresaId: json['empresa_id'] as String?,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );
  }

  /// Convierte a JSON para Supabase (snake_case)
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (id.isNotEmpty) 'id': id,  // ✅ Solo incluir id si no está vacío
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'vehiculo_id': vehiculoId,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo.toSnakeCase(),
      'resultado': resultado.toSnakeCase(),
      'km_vehiculo': kmVehiculo,
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'observaciones': observaciones,
      'taller': taller,
      'numero_documento': numeroDocumento,
      'costo_total': costoTotal,
      'estado': estado.toSnakeCase(),
      'empresa_id': empresaId,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  /// Convierte el modelo a entidad de dominio
  ItvRevisionEntity toEntity() {
    return ItvRevisionEntity(
      id: id,
      vehiculoId: vehiculoId,
      fecha: fecha,
      tipo: tipo,
      resultado: resultado,
      kmVehiculo: kmVehiculo,
      fechaVencimiento: fechaVencimiento,
      observaciones: observaciones,
      taller: taller,
      numeroDocumento: numeroDocumento,
      costoTotal: costoTotal,
      estado: estado,
      empresaId: empresaId,
      createdAt: createdAt,
      createdBy: createdBy,
      updatedAt: updatedAt,
      updatedBy: updatedBy,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory ItvRevisionSupabaseModel.fromEntity(ItvRevisionEntity entity) {
    return ItvRevisionSupabaseModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      fecha: entity.fecha,
      tipo: entity.tipo,
      resultado: entity.resultado,
      kmVehiculo: entity.kmVehiculo,
      fechaVencimiento: entity.fechaVencimiento,
      observaciones: entity.observaciones,
      taller: entity.taller,
      numeroDocumento: entity.numeroDocumento,
      costoTotal: entity.costoTotal,
      estado: entity.estado,
      empresaId: entity.empresaId,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
      updatedAt: entity.updatedAt,
      updatedBy: entity.updatedBy,
    );
  }
}
