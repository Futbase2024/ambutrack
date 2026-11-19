import 'package:json_annotation/json_annotation.dart';

import '../entities/plantilla_turno_entity.dart';
import '../entities/turno_entity.dart';

part 'plantilla_turno_supabase_model.g.dart';

/// Modelo DTO para PlantillaTurno en Supabase (mapeo tabla `plantillas_turnos`)
@JsonSerializable()
class PlantillaTurnoSupabaseModel {
  const PlantillaTurnoSupabaseModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.tipoTurno,
    required this.horaInicio,
    required this.horaFin,
    this.color,
    this.duracionDias = 1,
    this.observaciones,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  /// ID único de la plantilla
  final String id;

  /// Nombre descriptivo de la plantilla
  final String nombre;

  /// Descripción opcional
  final String? descripcion;

  /// Tipo de turno como string (enum.name)
  @JsonKey(name: 'tipo_turno')
  final String tipoTurno;

  /// Hora de inicio en formato HH:mm
  @JsonKey(name: 'hora_inicio')
  final String horaInicio;

  /// Hora de fin en formato HH:mm
  @JsonKey(name: 'hora_fin')
  final String horaFin;

  /// Color hexadecimal personalizado (#RRGGBB)
  final String? color;

  /// Duración en días (no existe columna en BD, solo en dominio)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final int duracionDias;

  /// Observaciones (no existe columna en BD, solo en dominio)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? observaciones;

  /// Estado activo
  final bool activo;

  /// Fecha de creación en BD
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización en BD
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Deserialización desde JSON (Supabase)
  factory PlantillaTurnoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$PlantillaTurnoSupabaseModelFromJson(json);

  /// Serialización a JSON (Supabase)
  Map<String, dynamic> toJson() => _$PlantillaTurnoSupabaseModelToJson(this);

  /// Crea un modelo desde una entidad de dominio
  factory PlantillaTurnoSupabaseModel.fromEntity(PlantillaTurnoEntity entity) {
    return PlantillaTurnoSupabaseModel(
      id: entity.id,
      nombre: entity.nombre,
      descripcion: entity.descripcion,
      tipoTurno: entity.tipoTurno.name,
      horaInicio: entity.horaInicio,
      horaFin: entity.horaFin,
      color: entity.color,
      duracionDias: entity.duracionDias,
      observaciones: entity.observaciones,
      activo: entity.activo,
    );
  }

  /// Convierte el modelo a entidad de dominio
  PlantillaTurnoEntity toEntity() {
    return PlantillaTurnoEntity(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      tipoTurno: _parseTipoTurno(tipoTurno),
      horaInicio: _normalizarHora(horaInicio),
      horaFin: _normalizarHora(horaFin),
      color: color,
      duracionDias: duracionDias,
      observaciones: observaciones,
      activo: activo,
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

  /// Postgres devuelve TIME como HH:mm:ss → normalizar a HH:mm
  static String _normalizarHora(String value) {
    return value.length >= 5 ? value.substring(0, 5) : value;
  }

  /// Parsea string a enum TipoTurno (acepta 'mañana' de BD)
  static TipoTurno _parseTipoTurno(String value) {
    final String normalizado = value.toLowerCase().replaceAll('ñ', 'n');
    return TipoTurno.values.firstWhere(
      (e) => e.name == normalizado,
      orElse: () => TipoTurno.personalizado,
    );
  }
}
