import 'package:json_annotation/json_annotation.dart';
import '../entities/cuadrante_asignacion_entity.dart';

part 'cuadrante_asignacion_supabase_model.g.dart';

/// Modelo de datos para serialización JSON de Cuadrante Asignación con Supabase
@JsonSerializable(explicitToJson: true)
class CuadranteAsignacionSupabaseModel {
  const CuadranteAsignacionSupabaseModel({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.cruzaMedianoche,
    required this.idPersonal,
    required this.nombrePersonal,
    this.categoriaPersonal,
    required this.tipoTurno,
    this.plantillaTurnoId,
    this.idVehiculo,
    this.matriculaVehiculo,
    required this.idDotacion,
    required this.nombreDotacion,
    required this.numeroUnidad,
    this.idHospital,
    this.idBase,
    required this.estado,
    this.confirmadaPor,
    this.fechaConfirmacion,
    this.kmInicial,
    this.kmFinal,
    required this.serviciosRealizados,
    this.horasEfectivas,
    this.observaciones,
    this.metadata,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  final String id;
  final DateTime fecha;
  @JsonKey(name: 'hora_inicio')
  final String horaInicio;
  @JsonKey(name: 'hora_fin')
  final String horaFin;
  @JsonKey(name: 'cruza_medianoche')
  final bool cruzaMedianoche;
  @JsonKey(name: 'id_personal')
  final String idPersonal;
  @JsonKey(name: 'nombre_personal')
  final String nombrePersonal;
  @JsonKey(name: 'categoria_personal')
  final String? categoriaPersonal;
  @JsonKey(name: 'tipo_turno')
  final String tipoTurno;
  @JsonKey(name: 'plantilla_turno_id')
  final String? plantillaTurnoId;
  @JsonKey(name: 'id_vehiculo')
  final String? idVehiculo;
  @JsonKey(name: 'matricula_vehiculo')
  final String? matriculaVehiculo;
  @JsonKey(name: 'id_dotacion')
  final String idDotacion;
  @JsonKey(name: 'nombre_dotacion')
  final String nombreDotacion;
  @JsonKey(name: 'numero_unidad')
  final int numeroUnidad;
  @JsonKey(name: 'id_hospital')
  final String? idHospital;
  @JsonKey(name: 'id_base')
  final String? idBase;
  final String estado;
  @JsonKey(name: 'confirmada_por')
  final String? confirmadaPor;
  @JsonKey(name: 'fecha_confirmacion')
  final DateTime? fechaConfirmacion;
  @JsonKey(name: 'km_inicial')
  final double? kmInicial;
  @JsonKey(name: 'km_final')
  final double? kmFinal;
  @JsonKey(name: 'servicios_realizados')
  final int serviciosRealizados;
  @JsonKey(name: 'horas_efectivas')
  final double? horasEfectivas;
  final String? observaciones;
  final Map<String, dynamic>? metadata;
  final bool activo;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  /// Crea una instancia desde JSON
  factory CuadranteAsignacionSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$CuadranteAsignacionSupabaseModelFromJson(json);

  /// Convierte la instancia a JSON
  Map<String, dynamic> toJson() => _$CuadranteAsignacionSupabaseModelToJson(this);

  /// Convierte el modelo a entidad de dominio
  CuadranteAsignacionEntity toEntity() {
    return CuadranteAsignacionEntity(
      id: id,
      fecha: fecha,
      horaInicio: horaInicio,
      horaFin: horaFin,
      cruzaMedianoche: cruzaMedianoche,
      idPersonal: idPersonal,
      nombrePersonal: nombrePersonal,
      categoriaPersonal: categoriaPersonal,
      tipoTurno: _parseTipoTurno(tipoTurno),
      plantillaTurnoId: plantillaTurnoId,
      idVehiculo: idVehiculo,
      matriculaVehiculo: matriculaVehiculo,
      idDotacion: idDotacion,
      nombreDotacion: nombreDotacion,
      numeroUnidad: numeroUnidad,
      idHospital: idHospital,
      idBase: idBase,
      estado: _parseEstado(estado),
      confirmadaPor: confirmadaPor,
      fechaConfirmacion: fechaConfirmacion,
      kmInicial: kmInicial,
      kmFinal: kmFinal,
      serviciosRealizados: serviciosRealizados,
      horasEfectivas: horasEfectivas,
      observaciones: observaciones,
      metadata: metadata,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Crea un modelo desde entidad de dominio
  factory CuadranteAsignacionSupabaseModel.fromEntity(
      CuadranteAsignacionEntity entity) {
    return CuadranteAsignacionSupabaseModel(
      id: entity.id,
      fecha: entity.fecha,
      horaInicio: entity.horaInicio,
      horaFin: entity.horaFin,
      cruzaMedianoche: entity.cruzaMedianoche,
      idPersonal: entity.idPersonal,
      nombrePersonal: entity.nombrePersonal,
      categoriaPersonal: entity.categoriaPersonal,
      tipoTurno: entity.tipoTurno.value,
      plantillaTurnoId: entity.plantillaTurnoId,
      idVehiculo: entity.idVehiculo,
      matriculaVehiculo: entity.matriculaVehiculo,
      idDotacion: entity.idDotacion,
      nombreDotacion: entity.nombreDotacion,
      numeroUnidad: entity.numeroUnidad,
      idHospital: entity.idHospital,
      idBase: entity.idBase,
      estado: entity.estado.value,
      confirmadaPor: entity.confirmadaPor,
      fechaConfirmacion: entity.fechaConfirmacion,
      kmInicial: entity.kmInicial,
      kmFinal: entity.kmFinal,
      serviciosRealizados: entity.serviciosRealizados,
      horasEfectivas: entity.horasEfectivas,
      observaciones: entity.observaciones,
      metadata: entity.metadata,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  /// Parsea string a enum TipoTurnoAsignacion
  static TipoTurnoAsignacion _parseTipoTurno(String value) {
    return TipoTurnoAsignacion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TipoTurnoAsignacion.personalizado,
    );
  }

  /// Parsea string a enum EstadoAsignacion
  static EstadoAsignacion _parseEstado(String value) {
    return EstadoAsignacion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EstadoAsignacion.planificada,
    );
  }
}
