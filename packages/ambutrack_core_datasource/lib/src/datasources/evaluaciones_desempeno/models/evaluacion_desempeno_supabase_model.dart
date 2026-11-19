import '../entities/evaluacion_desempeno_entity.dart';

DateTime? _date(dynamic value) => value == null ? null : DateTime.parse(value as String);

/// Fecha sin hora (columna DATE)
String _day(DateTime value) {
  final String m = value.month.toString().padLeft(2, '0');
  final String d = value.day.toString().padLeft(2, '0');
  return '${value.year.toString().padLeft(4, '0')}-$m-$d';
}

int _int(dynamic value) => (value as num?)?.toInt() ?? EvaluacionDesempenoEntity.minPuntuacion;

String? _nombreCompleto(dynamic relation) {
  if (relation is! Map<String, dynamic>) {
    return null;
  }
  final String nombre = '${relation['nombre'] ?? ''} ${relation['apellidos'] ?? ''}'.trim();
  return nombre.isEmpty ? null : nombre;
}

/// Model: Serialización JSON para tevaluaciones_desempeno
class EvaluacionDesempenoSupabaseModel {
  EvaluacionDesempenoSupabaseModel({
    required this.id,
    required this.empresaId,
    required this.personalId,
    required this.fecha,
    this.periodo,
    this.evaluadorId,
    this.evaluadorNombre,
    required this.puntualidad,
    required this.tratoPaciente,
    required this.trabajoEquipo,
    required this.cumplimientoProtocolos,
    this.puntuacionMedia,
    this.comentarios,
    this.createdAt,
    this.updatedAt,
    this.personalNombre,
  });

  /// Select con join para mostrar el nombre del trabajador
  static const String selectWithJoins = '*, personal:tpersonal(nombre, apellidos)';

  final String id;
  final String empresaId;
  final String personalId;
  final DateTime fecha;
  final String? periodo;
  final String? evaluadorId;
  final String? evaluadorNombre;
  final int puntualidad;
  final int tratoPaciente;
  final int trabajoEquipo;
  final int cumplimientoProtocolos;
  final double? puntuacionMedia;
  final String? comentarios;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? personalNombre;

  factory EvaluacionDesempenoSupabaseModel.fromJson(Map<String, dynamic> json) {
    return EvaluacionDesempenoSupabaseModel(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String? ?? '',
      personalId: json['personal_id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      periodo: json['periodo'] as String?,
      evaluadorId: json['evaluador_id'] as String?,
      evaluadorNombre: json['evaluador_nombre'] as String?,
      puntualidad: _int(json['puntualidad']),
      tratoPaciente: _int(json['trato_paciente']),
      trabajoEquipo: _int(json['trabajo_equipo']),
      cumplimientoProtocolos: _int(json['cumplimiento_protocolos']),
      puntuacionMedia: (json['puntuacion_media'] as num?)?.toDouble(),
      comentarios: json['comentarios'] as String?,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
      personalNombre: _nombreCompleto(json['personal']),
    );
  }

  factory EvaluacionDesempenoSupabaseModel.fromEntity(EvaluacionDesempenoEntity e) {
    return EvaluacionDesempenoSupabaseModel(
      id: e.id,
      empresaId: e.empresaId,
      personalId: e.personalId,
      fecha: e.fecha,
      periodo: e.periodo,
      evaluadorId: e.evaluadorId,
      evaluadorNombre: e.evaluadorNombre,
      puntualidad: e.puntualidad,
      tratoPaciente: e.tratoPaciente,
      trabajoEquipo: e.trabajoEquipo,
      cumplimientoProtocolos: e.cumplimientoProtocolos,
      comentarios: e.comentarios,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
    );
  }

  /// JSON para insert/update. Excluye la columna generada (puntuacion_media),
  /// timestamps y empresa_id vacío (lo rellena el trigger).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      if (empresaId.isNotEmpty) 'empresa_id': empresaId,
      'personal_id': personalId,
      'fecha': _day(fecha),
      'periodo': periodo,
      if (evaluadorId != null) 'evaluador_id': evaluadorId,
      'evaluador_nombre': evaluadorNombre,
      'puntualidad': puntualidad,
      'trato_paciente': tratoPaciente,
      'trabajo_equipo': trabajoEquipo,
      'cumplimiento_protocolos': cumplimientoProtocolos,
      'comentarios': comentarios,
    };
  }

  EvaluacionDesempenoEntity toEntity() {
    return EvaluacionDesempenoEntity(
      id: id,
      empresaId: empresaId,
      personalId: personalId,
      fecha: fecha,
      periodo: periodo,
      evaluadorId: evaluadorId,
      evaluadorNombre: evaluadorNombre,
      puntualidad: puntualidad,
      tratoPaciente: tratoPaciente,
      trabajoEquipo: trabajoEquipo,
      cumplimientoProtocolos: cumplimientoProtocolos,
      puntuacionMedia: puntuacionMedia,
      comentarios: comentarios,
      createdAt: createdAt,
      updatedAt: updatedAt,
      personalNombre: personalNombre,
    );
  }
}
