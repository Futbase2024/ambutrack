import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';

import '../entities/alerta_caducidad_entity.dart';

part 'alerta_caducidad_supabase_model.g.dart';

/// Modelo de datos para Alertas de Caducidad desde/hacia Supabase
/// DTO con serialización JSON automática
@JsonSerializable(explicitToJson: true)
class AlertaCaducidadSupabaseModel {
  const AlertaCaducidadSupabaseModel({
    this.id,  // ✅ Opcional - no viene de Supabase
    required this.tipoAlerta,
    required this.entidadId,
    required this.entidadKey,
    required this.entidadNombre,
    required this.fechaCaducidad,
    required this.diasRestantes,
    required this.severidad,
    required this.tablaOrigen,
    required this.esCritica,
    required this.prioridad,
  });

  final String? id;  // ✅ Opcional - generado desde entidadKey

  @JsonKey(name: 'tipo_alerta')
  final String tipoAlerta;

  @JsonKey(name: 'entidad_id')
  final String entidadId;

  @JsonKey(name: 'entidad_key')
  final String entidadKey;

  @JsonKey(name: 'entidad_nombre')
  final String entidadNombre;

  @JsonKey(name: 'fecha_caducidad')
  final DateTime fechaCaducidad;

  @JsonKey(name: 'dias_restantes')
  final int diasRestantes;

  final String severidad;

  @JsonKey(name: 'tabla_origen')
  final String tablaOrigen;

  @JsonKey(name: 'es_critica')
  final bool esCritica;

  final int prioridad;

  /// Deserialización desde JSON (Supabase → Model)
  factory AlertaCaducidadSupabaseModel.fromJson(
          Map<String, dynamic> json) =>
      _$AlertaCaducidadSupabaseModelFromJson(json);

  /// Serialización a JSON (Model → Supabase)
  Map<String, dynamic> toJson() =>
      _$AlertaCaducidadSupabaseModelToJson(this);

  /// Conversión a Entity (Model → Domain)
  AlertaCaducidadEntity toEntity() {
    return AlertaCaducidadEntity(
      id: id ?? entidadKey,  // ✅ Usar entidadKey como id si id es null
      tipo: _parseTipoAlerta(tipoAlerta),
      entidadId: entidadId,
      entidadKey: entidadKey,
      entidadNombre: entidadNombre,
      fechaCaducidad: fechaCaducidad,
      diasRestantes: diasRestantes,
      severidad: _parseSeveridad(severidad),
      tablaOrigen: tablaOrigen,
      esCritica: esCritica,
      prioridad: prioridad,
    );
  }

  /// Parsea el tipo de alerta desde string
  AlertaTipo _parseTipoAlerta(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'seguro':
        return AlertaTipo.seguro;
      case 'itv':
        return AlertaTipo.itv;
      case 'homologacion':
        return AlertaTipo.homologacion;
      case 'revision_tecnica':
      case 'revisiontecnica':
        return AlertaTipo.revisionTecnica;
      case 'revision':
        return AlertaTipo.revision;
      case 'mantenimiento':
        return AlertaTipo.mantenimiento;
      default:
        debugPrint('⚠️ Tipo de alerta desconocido: $tipo, usando itv como fallback');
        return AlertaTipo.itv;
    }
  }

  /// Parsea la severidad desde string
  AlertaSeveridad _parseSeveridad(String severidad) {
    switch (severidad.toLowerCase()) {
      case 'critica':
        return AlertaSeveridad.critica;
      case 'alta':
        return AlertaSeveridad.alta;
      case 'media':
        return AlertaSeveridad.media;
      case 'baja':
        return AlertaSeveridad.baja;
      default:
        throw ArgumentError('Severidad desconocida: $severidad');
    }
  }
}

/// Modelo de datos para el resumen de alertas desde/hacia Supabase
@JsonSerializable(explicitToJson: true)
class AlertasResumenSupabaseModel {
  const AlertasResumenSupabaseModel({
    required this.criticas,
    required this.altas,
    required this.medias,
    required this.bajas,
    required this.total,
  });

  final int criticas;
  final int altas;
  final int medias;
  final int bajas;
  final int total;

  /// Deserialización desde JSON (Supabase → Model)
  factory AlertasResumenSupabaseModel.fromJson(
          Map<String, dynamic> json) =>
      _$AlertasResumenSupabaseModelFromJson(json);

  /// Serialización a JSON (Model → Supabase)
  Map<String, dynamic> toJson() =>
      _$AlertasResumenSupabaseModelToJson(this);

  /// Conversión a Entity (Model → Domain)
  AlertasResumenEntity toEntity() {
    return AlertasResumenEntity(
      criticas: criticas,
      altas: altas,
      medias: medias,
      bajas: bajas,
      total: total,
    );
  }
}
