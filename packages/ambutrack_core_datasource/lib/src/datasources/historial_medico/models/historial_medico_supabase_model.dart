import 'package:json_annotation/json_annotation.dart';

import '../entities/historial_medico_entity.dart';

part 'historial_medico_supabase_model.g.dart';

/// Modelo Supabase para Historial Médico del Personal
@JsonSerializable()
class HistorialMedicoSupabaseModel {
  const HistorialMedicoSupabaseModel({
    required this.id,
    required this.personalId,
    required this.fechaReconocimiento,
    required this.fechaCaducidad,
    required this.aptitud,
    this.observaciones,
    this.restricciones,
    this.centroMedico,
    this.nombreMedico,
    this.documentoUrl,
    required this.activo,
    this.createdAt,
    this.updatedAt,
  });

  /// ID único del registro de historial médico
  final String id;

  /// ID del personal asociado (FK a tabla personal)
  @JsonKey(name: 'personal_id')
  final String personalId;

  /// Fecha del reconocimiento médico
  @JsonKey(name: 'fecha_reconocimiento')
  final DateTime fechaReconocimiento;

  /// Fecha de caducidad del reconocimiento
  @JsonKey(name: 'fecha_caducidad')
  final DateTime fechaCaducidad;

  /// Aptitud médica (apto, apto_con_restricciones, no_apto)
  final String aptitud;

  /// Observaciones del reconocimiento médico
  final String? observaciones;

  /// Restricciones médicas (si las hay)
  final String? restricciones;

  /// Centro médico donde se realizó el reconocimiento
  @JsonKey(name: 'centro_medico')
  final String? centroMedico;

  /// Nombre del médico que realizó el reconocimiento
  @JsonKey(name: 'nombre_medico')
  final String? nombreMedico;

  /// URL del documento del reconocimiento médico
  @JsonKey(name: 'documento_url')
  final String? documentoUrl;

  /// Estado activo/inactivo
  final bool activo;

  /// Fecha de creación del registro
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// Fecha de última actualización
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// Convierte el modelo a entidad de dominio
  HistorialMedicoEntity toEntity() {
    return HistorialMedicoEntity(
      id: id,
      personalId: personalId,
      fechaReconocimiento: fechaReconocimiento,
      fechaCaducidad: fechaCaducidad,
      aptitud: aptitud,
      observaciones: observaciones,
      restricciones: restricciones,
      centroMedico: centroMedico,
      nombreMedico: nombreMedico,
      documentoUrl: documentoUrl,
      activo: activo,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Crea un modelo desde una entidad de dominio
  factory HistorialMedicoSupabaseModel.fromEntity(HistorialMedicoEntity entity) {
    return HistorialMedicoSupabaseModel(
      id: entity.id,
      personalId: entity.personalId,
      fechaReconocimiento: entity.fechaReconocimiento,
      fechaCaducidad: entity.fechaCaducidad,
      aptitud: entity.aptitud,
      observaciones: entity.observaciones,
      restricciones: entity.restricciones,
      centroMedico: entity.centroMedico,
      nombreMedico: entity.nombreMedico,
      documentoUrl: entity.documentoUrl,
      activo: entity.activo,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Deserialización desde JSON
  factory HistorialMedicoSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$HistorialMedicoSupabaseModelFromJson(json);

  /// Serialización a JSON
  Map<String, dynamic> toJson() => _$HistorialMedicoSupabaseModelToJson(this);

  /// Copia con modificaciones
  HistorialMedicoSupabaseModel copyWith({
    String? id,
    String? personalId,
    DateTime? fechaReconocimiento,
    DateTime? fechaCaducidad,
    String? aptitud,
    String? observaciones,
    String? restricciones,
    String? centroMedico,
    String? nombreMedico,
    String? documentoUrl,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistorialMedicoSupabaseModel(
      id: id ?? this.id,
      personalId: personalId ?? this.personalId,
      fechaReconocimiento: fechaReconocimiento ?? this.fechaReconocimiento,
      fechaCaducidad: fechaCaducidad ?? this.fechaCaducidad,
      aptitud: aptitud ?? this.aptitud,
      observaciones: observaciones ?? this.observaciones,
      restricciones: restricciones ?? this.restricciones,
      centroMedico: centroMedico ?? this.centroMedico,
      nombreMedico: nombreMedico ?? this.nombreMedico,
      documentoUrl: documentoUrl ?? this.documentoUrl,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
