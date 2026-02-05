import '../entities/registro_horario_entity.dart';

/// Modelo de Supabase para Registro Horario
///
/// Mapea directamente desde/hacia la tabla PostgreSQL 'registro_horarios'
class RegistroHorarioSupabaseModel {
  final String id;
  final String personalId;
  final String? nombrePersonal;
  final String tipo;
  final DateTime fechaHora;
  final String? ubicacion;
  final double? latitud;
  final double? longitud;
  final double? precisionGps;
  final String? notas;
  final String estado;
  final bool esManual;
  final String? usuarioManualId;
  final String? vehiculoId;
  final String? turno;
  final double? horasTrabajadas;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RegistroHorarioSupabaseModel({
    required this.id,
    required this.personalId,
    this.nombrePersonal,
    required this.tipo,
    required this.fechaHora,
    this.ubicacion,
    this.latitud,
    this.longitud,
    this.precisionGps,
    this.notas,
    this.estado = 'normal',
    this.esManual = false,
    this.usuarioManualId,
    this.vehiculoId,
    this.turno,
    this.horasTrabajadas,
    this.activo = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convierte desde JSON de Supabase
  factory RegistroHorarioSupabaseModel.fromJson(Map<String, dynamic> json) {
    return RegistroHorarioSupabaseModel(
      id: json['id'] as String,
      personalId: json['personal_id'] as String,
      nombrePersonal: json['nombre_personal'] as String?,
      tipo: json['tipo'] as String,
      fechaHora: DateTime.parse(json['fecha_hora'] as String),
      ubicacion: json['ubicacion'] as String?,
      latitud: json['latitud'] != null ? (json['latitud'] as num).toDouble() : null,
      longitud: json['longitud'] != null ? (json['longitud'] as num).toDouble() : null,
      precisionGps: json['precision_gps'] != null ? (json['precision_gps'] as num).toDouble() : null,
      notas: json['notas'] as String?,
      estado: json['estado'] as String? ?? 'normal',
      esManual: json['es_manual'] as bool? ?? false,
      usuarioManualId: json['usuario_manual_id'] as String?,
      vehiculoId: json['vehiculo_id'] as String?,
      turno: json['turno'] as String?,
      horasTrabajadas: json['horas_trabajadas'] != null
          ? (json['horas_trabajadas'] as num).toDouble()
          : null,
      activo: json['activo'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personal_id': personalId,
      'nombre_personal': nombrePersonal,
      'tipo': tipo,
      'fecha_hora': fechaHora.toIso8601String(),
      'ubicacion': ubicacion,
      'latitud': latitud,
      'longitud': longitud,
      'precision_gps': precisionGps,
      'notas': notas,
      'estado': estado,
      'es_manual': esManual,
      'usuario_manual_id': usuarioManualId,
      'vehiculo_id': vehiculoId,
      'turno': turno,
      'horas_trabajadas': horasTrabajadas,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convierte a entidad de dominio
  RegistroHorarioEntity toEntity() {
    return RegistroHorarioEntity(
      id: id,
      personalId: personalId,
      nombrePersonal: nombrePersonal,
      tipo: tipo,
      fechaHora: fechaHora,
      ubicacion: ubicacion,
      latitud: latitud,
      longitud: longitud,
      precisionGps: precisionGps,
      notas: notas,
      estado: estado,
      esManual: esManual,
      usuarioManualId: usuarioManualId,
      vehiculoId: vehiculoId,
      turno: turno,
      horasTrabajadas: horasTrabajadas,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea desde entidad de dominio
  factory RegistroHorarioSupabaseModel.fromEntity(RegistroHorarioEntity entity) {
    return RegistroHorarioSupabaseModel(
      id: entity.id,
      personalId: entity.personalId,
      nombrePersonal: entity.nombrePersonal,
      tipo: entity.tipo,
      fechaHora: entity.fechaHora,
      ubicacion: entity.ubicacion,
      latitud: entity.latitud,
      longitud: entity.longitud,
      precisionGps: entity.precisionGps,
      notas: entity.notas,
      estado: entity.estado,
      esManual: entity.esManual,
      usuarioManualId: entity.usuarioManualId,
      vehiculoId: entity.vehiculoId,
      turno: entity.turno,
      horasTrabajadas: entity.horasTrabajadas,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
