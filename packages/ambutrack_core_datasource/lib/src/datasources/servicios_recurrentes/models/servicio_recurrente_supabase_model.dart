import 'package:json_annotation/json_annotation.dart';

import '../entities/servicio_recurrente_entity.dart';

part 'servicio_recurrente_supabase_model.g.dart';

/// Modelo de datos para Servicios Recurrentes desde/hacia Supabase
/// DTO con serialización JSON automática
@JsonSerializable(explicitToJson: true)
class ServicioRecurrenteSupabaseModel {
  const ServicioRecurrenteSupabaseModel({
    required this.id,
    required this.codigo,
    required this.idServicio,
    required this.idPaciente,
    required this.tipoRecurrencia,
    this.diasSemana,
    this.intervaloSemanas,
    this.intervaloDias,
    this.diasMes,
    this.fechasEspecificas,
    required this.fechaServicioInicio,
    this.fechaServicioFin,
    required this.horaRecogida,
    this.horaVuelta,
    this.requiereVuelta,
    this.idMotivoTraslado,
    this.tipoAmbulancia,
    this.requiereAcompanante,
    this.requiereSillaRuedas,
    this.requiereCamilla,
    this.requiereAyuda,
    this.tipoOrigen,
    this.origen,
    this.origenUbicacionCentro,
    this.tipoDestino,
    this.destino,
    this.destinoUbicacionCentro,
    this.observaciones,
    this.observacionesMedicas,
    this.prioridad,
    this.trasladosGeneradosHasta,
    this.activo,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  final String id;
  final String codigo;

  @JsonKey(name: 'id_servicio')
  final String idServicio;

  @JsonKey(name: 'id_paciente')
  final String idPaciente;

  @JsonKey(name: 'tipo_recurrencia')
  final String tipoRecurrencia;

  @JsonKey(name: 'dias_semana')
  final List<int>? diasSemana;

  @JsonKey(name: 'intervalo_semanas')
  final int? intervaloSemanas;

  @JsonKey(name: 'intervalo_dias')
  final int? intervaloDias;

  @JsonKey(name: 'dias_mes')
  final List<int>? diasMes;

  @JsonKey(name: 'fechas_especificas')
  final List<String>? fechasEspecificas; // ISO strings

  @JsonKey(name: 'fecha_servicio_inicio')
  final String fechaServicioInicio; // DATE as ISO string

  @JsonKey(name: 'fecha_servicio_fin')
  final String? fechaServicioFin; // DATE as ISO string

  @JsonKey(name: 'hora_recogida')
  final String horaRecogida; // TIME as string (HH:mm:ss)

  @JsonKey(name: 'hora_vuelta')
  final String? horaVuelta; // TIME as string (HH:mm:ss)

  @JsonKey(name: 'requiere_vuelta')
  final bool? requiereVuelta;

  @JsonKey(name: 'id_motivo_traslado')
  final String? idMotivoTraslado;

  // ✅ REQUISITOS DE AMBULANCIA
  @JsonKey(name: 'tipo_ambulancia')
  final String? tipoAmbulancia;

  @JsonKey(name: 'requiere_acompanante')
  final bool? requiereAcompanante;

  @JsonKey(name: 'requiere_silla_ruedas')
  final bool? requiereSillaRuedas;

  @JsonKey(name: 'requiere_camilla')
  final bool? requiereCamilla;

  @JsonKey(name: 'requiere_ayuda')
  final bool? requiereAyuda;

  // ✅ UBICACIONES (tipo_ubicacion ENUM + valor específico)
  @JsonKey(name: 'tipo_origen')
  final String? tipoOrigen; // 'domicilio_paciente', 'otro_domicilio', 'centro_hospitalario'

  @JsonKey(name: 'origen')
  final String? origen; // ID centro o dirección según tipo_origen

  @JsonKey(name: 'origen_ubicacion_centro')
  final String? origenUbicacionCentro; // Nombre ubicación dentro del centro (ej: "Urgencias")

  @JsonKey(name: 'tipo_destino')
  final String? tipoDestino; // 'domicilio_paciente', 'otro_domicilio', 'centro_hospitalario'

  @JsonKey(name: 'destino')
  final String? destino; // ID centro o dirección según tipo_destino

  @JsonKey(name: 'destino_ubicacion_centro')
  final String? destinoUbicacionCentro; // Nombre ubicación dentro del centro (ej: "Consultas Externas")

  final String? observaciones;

  @JsonKey(name: 'observaciones_medicas')
  final String? observacionesMedicas;

  final int? prioridad;

  @JsonKey(name: 'traslados_generados_hasta')
  final String? trasladosGeneradosHasta; // DATE as ISO string

  final bool? activo;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'created_by')
  final String? createdBy;

  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  /// Deserialización desde JSON (Supabase → Model)
  factory ServicioRecurrenteSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$ServicioRecurrenteSupabaseModelFromJson(json);

  /// Serialización a JSON (Model → Supabase)
  Map<String, dynamic> toJson() => _$ServicioRecurrenteSupabaseModelToJson(this);

  /// Conversión desde Entity (Domain → Model)
  factory ServicioRecurrenteSupabaseModel.fromEntity(ServicioRecurrenteEntity entity) {
    return ServicioRecurrenteSupabaseModel(
      id: entity.id,
      codigo: entity.codigo,
      idServicio: entity.idServicio,
      idPaciente: entity.idPaciente,
      tipoRecurrencia: entity.tipoRecurrencia,
      diasSemana: entity.diasSemana,
      intervaloSemanas: entity.intervaloSemanas,
      intervaloDias: entity.intervaloDias,
      diasMes: entity.diasMes,
      fechasEspecificas: entity.fechasEspecificas
          ?.map((fecha) => fecha.toIso8601String().split('T').first)
          .toList(),
      fechaServicioInicio: entity.fechaServicioInicio.toIso8601String().split('T').first,
      fechaServicioFin: entity.fechaServicioFin?.toIso8601String().split('T').first,
      horaRecogida: _formatTime(entity.horaRecogida),
      horaVuelta: entity.horaVuelta != null ? _formatTime(entity.horaVuelta!) : null,
      requiereVuelta: entity.requiereVuelta,
      idMotivoTraslado: entity.idMotivoTraslado,
      tipoAmbulancia: entity.tipoAmbulancia,
      requiereAcompanante: entity.requiereAcompanante,
      requiereSillaRuedas: entity.requiereSillaRuedas,
      requiereCamilla: entity.requiereCamilla,
      requiereAyuda: entity.requiereAyuda,
      tipoOrigen: entity.tipoOrigen,
      origen: entity.origen,
      origenUbicacionCentro: entity.origenUbicacionCentro,
      tipoDestino: entity.tipoDestino,
      destino: entity.destino,
      destinoUbicacionCentro: entity.destinoUbicacionCentro,
      observaciones: entity.observaciones,
      observacionesMedicas: entity.observacionesMedicas,
      prioridad: entity.prioridad,
      trasladosGeneradosHasta: entity.trasladosGeneradosHasta?.toIso8601String().split('T').first,
      activo: entity.activo,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  /// Conversión a Entity (Model → Domain)
  ServicioRecurrenteEntity toEntity() {
    return ServicioRecurrenteEntity(
      id: id,
      codigo: codigo,
      idServicio: idServicio,
      idPaciente: idPaciente,
      tipoRecurrencia: tipoRecurrencia,
      diasSemana: diasSemana,
      intervaloSemanas: intervaloSemanas,
      intervaloDias: intervaloDias,
      diasMes: diasMes,
      fechasEspecificas: fechasEspecificas
          ?.map((fecha) => DateTime.parse(fecha))
          .toList(),
      fechaServicioInicio: DateTime.parse(fechaServicioInicio),
      fechaServicioFin: fechaServicioFin != null ? DateTime.parse(fechaServicioFin!) : null,
      horaRecogida: _parseTime(horaRecogida),
      horaVuelta: horaVuelta != null ? _parseTime(horaVuelta!) : null,
      requiereVuelta: requiereVuelta ?? false,
      idMotivoTraslado: idMotivoTraslado,
      tipoAmbulancia: tipoAmbulancia,
      requiereAcompanante: requiereAcompanante,
      requiereSillaRuedas: requiereSillaRuedas,
      requiereCamilla: requiereCamilla,
      requiereAyuda: requiereAyuda,
      tipoOrigen: tipoOrigen,
      origen: origen,
      origenUbicacionCentro: origenUbicacionCentro,
      tipoDestino: tipoDestino,
      destino: destino,
      destinoUbicacionCentro: destinoUbicacionCentro,
      observaciones: observaciones,
      observacionesMedicas: observacionesMedicas,
      prioridad: prioridad ?? 5,
      trasladosGeneradosHasta: trasladosGeneradosHasta != null
          ? DateTime.parse(trasladosGeneradosHasta!)
          : null,
      activo: activo ?? true,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
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
