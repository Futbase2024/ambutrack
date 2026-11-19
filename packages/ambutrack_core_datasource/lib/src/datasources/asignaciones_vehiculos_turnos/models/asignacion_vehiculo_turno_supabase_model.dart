import 'package:json_annotation/json_annotation.dart';

import '../entities/asignacion_vehiculo_turno_entity.dart';

part 'asignacion_vehiculo_turno_supabase_model.g.dart';

/// Modelo DTO para Asignación Vehículo-Turno en Supabase (mapeo tabla `asignaciones_vehiculos_turnos`)
@JsonSerializable()
class AsignacionVehiculoTurnoSupabaseModel {
  const AsignacionVehiculoTurnoSupabaseModel({
    required this.id,
    required this.vehiculoId,
    required this.dotacionId,
    required this.fecha,
    this.plantillaTurnoId,
    this.baseId,
    this.hospitalId,
    this.estado = 'planificada',
    this.confirmadaPor,
    this.fechaConfirmacion,
    this.kmInicial,
    this.kmFinal,
    this.serviciosRealizados = 0,
    this.horasEfectivas,
    this.observaciones,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  /// ID único de la asignación
  final String id;

  /// ID del vehículo asignado
  @JsonKey(name: 'vehiculo_id')
  final String vehiculoId;

  /// ID de la dotación
  @JsonKey(name: 'dotacion_id')
  final String dotacionId;

  /// Fecha de la asignación
  final DateTime fecha;

  /// ID de la plantilla de turno (mañana, tarde, noche)
  @JsonKey(name: 'plantilla_turno_id')
  final String? plantillaTurnoId;

  /// ID de la base de origen (opcional)
  @JsonKey(name: 'base_id')
  final String? baseId;

  /// ID del hospital de destino (opcional)
  @JsonKey(name: 'hospital_id')
  final String? hospitalId;

  /// Estado de la asignación
  final String estado;

  /// Usuario que confirmó la asignación
  @JsonKey(name: 'confirmada_por')
  final String? confirmadaPor;

  /// Fecha de confirmación
  @JsonKey(name: 'fecha_confirmacion')
  final DateTime? fechaConfirmacion;

  /// Kilómetros iniciales
  @JsonKey(name: 'km_inicial')
  final double? kmInicial;

  /// Kilómetros finales
  @JsonKey(name: 'km_final')
  final double? kmFinal;

  /// Número de servicios realizados
  @JsonKey(name: 'servicios_realizados')
  final int? serviciosRealizados;

  /// Horas efectivas trabajadas
  @JsonKey(name: 'horas_efectivas')
  final double? horasEfectivas;

  /// Observaciones adicionales
  final String? observaciones;

  /// Metadatos adicionales en JSON
  final Map<String, dynamic>? metadata;

  /// Fecha de creación en BD
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización en BD
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Usuario que creó el registro
  @JsonKey(name: 'created_by')
  final String? createdBy;

  /// Usuario que actualizó el registro
  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  /// Deserialización desde JSON (Supabase)
  factory AsignacionVehiculoTurnoSupabaseModel.fromJson(
          Map<String, dynamic> json) =>
      _$AsignacionVehiculoTurnoSupabaseModelFromJson(json);

  /// Serialización a JSON (Supabase)
  Map<String, dynamic> toJson() =>
      _$AsignacionVehiculoTurnoSupabaseModelToJson(this);

  /// Crea un modelo desde una entidad de dominio
  factory AsignacionVehiculoTurnoSupabaseModel.fromEntity(
      AsignacionVehiculoTurnoEntity entity) {
    return AsignacionVehiculoTurnoSupabaseModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      dotacionId: entity.dotacionId,
      fecha: entity.fecha,
      plantillaTurnoId: entity.plantillaTurnoId,
      baseId: entity.baseId,
      hospitalId: entity.hospitalId,
      estado: entity.estado,
      confirmadaPor: entity.confirmadaPor,
      fechaConfirmacion: entity.fechaConfirmacion,
      kmInicial: entity.kmInicial,
      kmFinal: entity.kmFinal,
      serviciosRealizados: entity.serviciosRealizados,
      horasEfectivas: entity.horasEfectivas,
      observaciones: entity.observaciones,
      metadata: entity.metadata,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  /// Convierte el modelo a entidad de dominio
  AsignacionVehiculoTurnoEntity toEntity() {
    return AsignacionVehiculoTurnoEntity(
      id: id,
      vehiculoId: vehiculoId,
      dotacionId: dotacionId,
      fecha: fecha,
      plantillaTurnoId: plantillaTurnoId,
      baseId: baseId,
      hospitalId: hospitalId,
      estado: estado,
      confirmadaPor: confirmadaPor,
      fechaConfirmacion: fechaConfirmacion,
      kmInicial: kmInicial,
      kmFinal: kmFinal,
      serviciosRealizados: serviciosRealizados,
      horasEfectivas: horasEfectivas,
      observaciones: observaciones,
      metadata: metadata,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Convierte a JSON para operación INSERT (sin id, created_at, updated_at)
  Map<String, dynamic> toJsonForInsert() {
    final json = toJson();
    json
      ..remove('id')
      ..remove('created_at')
      ..remove('updated_at');
    return json;
  }
}
