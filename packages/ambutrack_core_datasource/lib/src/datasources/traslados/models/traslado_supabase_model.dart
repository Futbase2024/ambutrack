import 'package:json_annotation/json_annotation.dart';

import '../../motivos_traslado/entities/motivo_traslado_entity.dart';
import '../../motivos_traslado/models/motivo_traslado_supabase_model.dart';
import '../../pacientes/entities/paciente_entity.dart';
import '../../pacientes/models/paciente_supabase_model.dart';
import '../entities/traslado_entity.dart';

part 'traslado_supabase_model.g.dart';

/// Helper para parsear DateTime como UTC desde Supabase
/// Supabase devuelve timestamps sin 'Z', lo que causa que DateTime.parse()
/// los interprete como hora local. Esta función fuerza UTC.
DateTime? _parseAsUtc(String? dateStr) {
  if (dateStr == null) return null;
  // Si ya tiene 'Z', parsear normalmente
  if (dateStr.endsWith('Z')) return DateTime.parse(dateStr);
  // Si no tiene 'Z', agregarlo para forzar UTC
  return DateTime.parse('${dateStr}Z');
}

/// Modelo de datos para Traslados desde/hacia Supabase
/// DTO con serialización JSON automática
@JsonSerializable(explicitToJson: true)
class TrasladoSupabaseModel {
  const TrasladoSupabaseModel({
    required this.id,
    this.codigo,
    this.idServicioRecurrente,
    this.idServicio,
    this.idMotivoTraslado,
    this.motivoTraslado,
    this.idPaciente,
    this.paciente,
    this.tipoTraslado,
    this.fecha,
    this.horaProgramada,
    this.estado,
    this.idPersonalConductor,
    this.idPersonalEnfermero,
    this.idPersonalMedico,
    this.idVehiculo,
    this.matriculaVehiculo,
    this.tipoOrigen,
    this.origen,
    this.tipoDestino,
    this.destino,
    this.kmInicio,
    this.kmFin,
    this.kmTotales,
    this.observaciones,
    this.observacionesInternas,
    this.motivoCancelacion,
    this.motivoNoRealizacion,
    this.duracionEstimadaMinutos,
    this.duracionRealMinutos,
    this.prioridad,
    this.fechaEnviado,
    this.fechaRecibidoConductor,
    this.fechaEnOrigen,
    this.ubicacionEnOrigen,
    this.fechaSaliendoOrigen,
    this.ubicacionSaliendoOrigen,
    this.fechaEnTransito,
    this.ubicacionEnTransito,
    this.fechaEnDestino,
    this.ubicacionEnDestino,
    this.fechaFinalizado,
    this.ubicacionFinalizado,
    this.fechaCancelado,
    this.fechaSuspendido,
    this.fechaNoRealizado,
    this.idUsuarioAsignacion,
    this.fechaAsignacion,
    this.idUsuarioEnvio,
    this.fechaEnvio,
    this.idUsuarioCancelacion,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  final String id;
  final String? codigo; // Nullable - puede no tener código generado

  @JsonKey(name: 'id_servicio_recurrente')
  final String? idServicioRecurrente;

  @JsonKey(name: 'id_servicio')
  final String? idServicio;

  @JsonKey(name: 'id_motivo_traslado')
  final String? idMotivoTraslado;

  /// Motivo de traslado embebido (cargado cuando se hace JOIN con tmotivos_traslado)
  @JsonKey(name: 'tmotivos_traslado')
  final Map<String, dynamic>? motivoTraslado;

  @JsonKey(name: 'id_paciente')
  final String? idPaciente;

  /// Paciente embebido (cargado cuando se hace JOIN con pacientes)
  @JsonKey(name: 'pacientes')
  final Map<String, dynamic>? paciente;

  @JsonKey(name: 'tipo_traslado')
  final String? tipoTraslado; // Nullable - puede no especificarse

  final String? fecha; // Nullable - puede no tener fecha

  @JsonKey(name: 'hora_programada')
  final String? horaProgramada; // Nullable - puede no tener hora programada

  final String? estado; // Nullable - puede no tener estado inicial

  @JsonKey(name: 'id_conductor')
  final String? idPersonalConductor;

  @JsonKey(name: 'id_personal_enfermero')
  final String? idPersonalEnfermero;

  @JsonKey(name: 'id_personal_medico')
  final String? idPersonalMedico;

  @JsonKey(name: 'id_vehiculo')
  final String? idVehiculo;

  @JsonKey(name: 'matricula_vehiculo')
  final String? matriculaVehiculo;

  @JsonKey(name: 'tipo_origen')
  final String? tipoOrigen;

  final String? origen;

  @JsonKey(name: 'tipo_destino')
  final String? tipoDestino;

  final String? destino;

  @JsonKey(name: 'km_inicio')
  final double? kmInicio;

  @JsonKey(name: 'km_fin')
  final double? kmFin;

  @JsonKey(name: 'km_totales')
  final double? kmTotales;

  final String? observaciones;

  @JsonKey(name: 'observaciones_internas')
  final String? observacionesInternas;

  @JsonKey(name: 'motivo_cancelacion')
  final String? motivoCancelacion;

  @JsonKey(name: 'motivo_no_realizacion')
  final String? motivoNoRealizacion;

  @JsonKey(name: 'duracion_estimada_minutos')
  final int? duracionEstimadaMinutos;

  @JsonKey(name: 'duracion_real_minutos')
  final int? duracionRealMinutos;

  final int? prioridad;

  // CRONAS (timestamps)
  @JsonKey(name: 'fecha_enviado')
  final String? fechaEnviado;

  @JsonKey(name: 'fecha_recibido_conductor')
  final String? fechaRecibidoConductor;

  @JsonKey(name: 'fecha_en_origen')
  final String? fechaEnOrigen;

  @JsonKey(name: 'ubicacion_en_origen')
  final Map<String, dynamic>? ubicacionEnOrigen; // JSONB

  @JsonKey(name: 'fecha_saliendo_origen')
  final String? fechaSaliendoOrigen;

  @JsonKey(name: 'ubicacion_saliendo_origen')
  final Map<String, dynamic>? ubicacionSaliendoOrigen; // JSONB

  @JsonKey(name: 'fecha_en_transito')
  final String? fechaEnTransito;

  @JsonKey(name: 'ubicacion_en_transito')
  final Map<String, dynamic>? ubicacionEnTransito; // JSONB

  @JsonKey(name: 'fecha_en_destino')
  final String? fechaEnDestino;

  @JsonKey(name: 'ubicacion_en_destino')
  final Map<String, dynamic>? ubicacionEnDestino; // JSONB

  @JsonKey(name: 'fecha_finalizado')
  final String? fechaFinalizado;

  @JsonKey(name: 'ubicacion_finalizado')
  final Map<String, dynamic>? ubicacionFinalizado; // JSONB

  @JsonKey(name: 'fecha_cancelacion')
  final String? fechaCancelado;

  @JsonKey(name: 'fecha_suspendido')
  final String? fechaSuspendido;

  @JsonKey(name: 'fecha_no_realizado')
  final String? fechaNoRealizado;

  // AUDITORÍA DE ASIGNACIÓN
  @JsonKey(name: 'id_usuario_asignacion')
  final String? idUsuarioAsignacion;

  @JsonKey(name: 'fecha_asignacion')
  final String? fechaAsignacion;

  @JsonKey(name: 'id_usuario_envio')
  final String? idUsuarioEnvio;

  @JsonKey(name: 'fecha_envio')
  final String? fechaEnvio;

  @JsonKey(name: 'id_usuario_cancelacion')
  final String? idUsuarioCancelacion;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'created_by')
  final String? createdBy;

  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  /// Deserialización desde JSON (Supabase → Model)
  factory TrasladoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$TrasladoSupabaseModelFromJson(json);

  /// Serialización a JSON (Model → Supabase)
  Map<String, dynamic> toJson() => _$TrasladoSupabaseModelToJson(this);

  /// Conversión desde Entity (Domain → Model)
  factory TrasladoSupabaseModel.fromEntity(TrasladoEntity entity) {
    return TrasladoSupabaseModel(
      id: entity.id,
      codigo: entity.codigo,
      idServicioRecurrente: entity.idServicioRecurrente,
      idServicio: entity.idServicio,
      idMotivoTraslado: entity.idMotivoTraslado,
      // No se envía motivoTraslado embebido a Supabase (solo se lee)
      motivoTraslado: null,
      idPaciente: entity.idPaciente,
      // No se envía paciente embebido a Supabase (solo se lee)
      paciente: null,
      tipoTraslado: entity.tipoTraslado,
      fecha: entity.fecha?.toIso8601String().split('T').first,
      horaProgramada: entity.horaProgramada != null ? _formatTime(entity.horaProgramada!) : null,
      estado: entity.estado,
      idPersonalConductor: entity.idPersonalConductor,
      idPersonalEnfermero: entity.idPersonalEnfermero,
      idPersonalMedico: entity.idPersonalMedico,
      idVehiculo: entity.idVehiculo,
      matriculaVehiculo: entity.matriculaVehiculo,
      tipoOrigen: entity.tipoOrigen,
      origen: entity.origen,
      tipoDestino: entity.tipoDestino,
      destino: entity.destino,
      kmInicio: entity.kmInicio,
      kmFin: entity.kmFin,
      kmTotales: entity.kmTotales,
      observaciones: entity.observaciones,
      observacionesInternas: entity.observacionesInternas,
      motivoCancelacion: entity.motivoCancelacion,
      motivoNoRealizacion: entity.motivoNoRealizacion,
      duracionEstimadaMinutos: entity.duracionEstimadaMinutos,
      duracionRealMinutos: entity.duracionRealMinutos,
      prioridad: entity.prioridad,
      fechaEnviado: entity.fechaEnviado?.toIso8601String(),
      fechaRecibidoConductor: entity.fechaRecibidoConductor?.toIso8601String(),
      fechaEnOrigen: entity.fechaEnOrigen?.toIso8601String(),
      ubicacionEnOrigen: entity.ubicacionEnOrigen,
      fechaSaliendoOrigen: entity.fechaSaliendoOrigen?.toIso8601String(),
      ubicacionSaliendoOrigen: entity.ubicacionSaliendoOrigen,
      fechaEnTransito: entity.fechaEnTransito?.toIso8601String(),
      ubicacionEnTransito: entity.ubicacionEnTransito,
      fechaEnDestino: entity.fechaEnDestino?.toIso8601String(),
      ubicacionEnDestino: entity.ubicacionEnDestino,
      fechaFinalizado: entity.fechaFinalizado?.toIso8601String(),
      ubicacionFinalizado: entity.ubicacionFinalizado,
      fechaCancelado: entity.fechaCancelado?.toIso8601String(),
      fechaSuspendido: entity.fechaSuspendido?.toIso8601String(),
      fechaNoRealizado: entity.fechaNoRealizado?.toIso8601String(),
      idUsuarioAsignacion: entity.idUsuarioAsignacion,
      fechaAsignacion: entity.fechaAsignacion?.toIso8601String(),
      idUsuarioEnvio: entity.idUsuarioEnvio,
      fechaEnvio: entity.fechaEnvio?.toIso8601String(),
      idUsuarioCancelacion: entity.idUsuarioCancelacion,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  /// Conversión a Entity (Model → Domain)
  TrasladoEntity toEntity() {
    // Convertir paciente embebido si existe
    PacienteEntity? pacienteEntity;
    if (paciente != null) {
      try {
        pacienteEntity = PacienteSupabaseModel.fromJson(paciente!).toEntity();
      } catch (_) {
        // Si falla la conversión, dejarlo como null
        pacienteEntity = null;
      }
    }

    // Convertir motivo de traslado embebido si existe
    MotivoTrasladoEntity? motivoTrasladoEntity;
    if (motivoTraslado != null) {
      try {
        motivoTrasladoEntity = MotivoTrasladoSupabaseModel.fromJson(motivoTraslado!).toEntity();
      } catch (_) {
        // Si falla la conversión, dejarlo como null
        motivoTrasladoEntity = null;
      }
    }

    return TrasladoEntity(
      id: id,
      codigo: codigo,
      idServicioRecurrente: idServicioRecurrente,
      idServicio: idServicio,
      idMotivoTraslado: idMotivoTraslado,
      motivoTraslado: motivoTrasladoEntity,
      idPaciente: idPaciente,
      paciente: pacienteEntity,
      tipoTraslado: tipoTraslado,
      fecha: fecha != null ? DateTime.parse(fecha!) : null,
      horaProgramada: horaProgramada != null ? _parseTime(horaProgramada!) : null,
      estado: estado,
      idPersonalConductor: idPersonalConductor,
      idPersonalEnfermero: idPersonalEnfermero,
      idPersonalMedico: idPersonalMedico,
      idVehiculo: idVehiculo,
      matriculaVehiculo: matriculaVehiculo,
      tipoOrigen: tipoOrigen,
      origen: origen,
      tipoDestino: tipoDestino,
      destino: destino,
      kmInicio: kmInicio,
      kmFin: kmFin,
      kmTotales: kmTotales,
      observaciones: observaciones,
      observacionesInternas: observacionesInternas,
      motivoCancelacion: motivoCancelacion,
      motivoNoRealizacion: motivoNoRealizacion,
      duracionEstimadaMinutos: duracionEstimadaMinutos,
      duracionRealMinutos: duracionRealMinutos,
      prioridad: prioridad ?? 5,
      fechaEnviado: _parseAsUtc(fechaEnviado),
      fechaRecibidoConductor: _parseAsUtc(fechaRecibidoConductor),
      fechaEnOrigen: _parseAsUtc(fechaEnOrigen),
      ubicacionEnOrigen: ubicacionEnOrigen,
      fechaSaliendoOrigen: _parseAsUtc(fechaSaliendoOrigen),
      ubicacionSaliendoOrigen: ubicacionSaliendoOrigen,
      fechaEnTransito: _parseAsUtc(fechaEnTransito),
      ubicacionEnTransito: ubicacionEnTransito,
      fechaEnDestino: _parseAsUtc(fechaEnDestino),
      ubicacionEnDestino: ubicacionEnDestino,
      fechaFinalizado: _parseAsUtc(fechaFinalizado),
      ubicacionFinalizado: ubicacionFinalizado,
      fechaCancelado: _parseAsUtc(fechaCancelado),
      fechaSuspendido: _parseAsUtc(fechaSuspendido),
      fechaNoRealizado: _parseAsUtc(fechaNoRealizado),
      idUsuarioAsignacion: idUsuarioAsignacion,
      fechaAsignacion: _parseAsUtc(fechaAsignacion),
      idUsuarioEnvio: idUsuarioEnvio,
      fechaEnvio: _parseAsUtc(fechaEnvio),
      idUsuarioCancelacion: idUsuarioCancelacion,
      createdAt: _parseAsUtc(createdAt),
      updatedAt: _parseAsUtc(updatedAt),
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }

  /// Helper para formatear TIME desde DateTime
  static String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  /// Helper para parsear TIME string a DateTime (solo hora)
  static DateTime _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2].split('.').first) : 0,
    );
  }
}
