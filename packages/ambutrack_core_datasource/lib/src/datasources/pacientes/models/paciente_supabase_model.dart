import 'package:json_annotation/json_annotation.dart';

import '../entities/paciente_entity.dart';

part 'paciente_supabase_model.g.dart';

/// Modelo de datos para Pacientes desde/hacia Supabase
/// DTO con serialización JSON automática
@JsonSerializable(explicitToJson: true)
class PacienteSupabaseModel {
  const PacienteSupabaseModel({
    required this.id,
    this.identificacion,
    required this.nombre,
    required this.primerApellido,
    this.segundoApellido,
    required this.tipoDocumento,
    this.documento,
    this.seguridadSocial,
    this.numHistoria,
    required this.sexo,
    required this.fechaNacimiento,
    this.telefonoMovil,
    this.telefonoFijo,
    this.email,
    this.paisOrigen,
    this.profesion,
    this.recogidaLunes,
    this.recogidaMartes,
    this.recogidaMiercoles,
    this.recogidaJueves,
    this.recogidaViernes,
    this.recogidaSabado,
    this.recogidaDomingo,
    this.recogidaFestivos,
    this.recogidaPiso,
    this.recogidaPuerta,
    this.recogidaLatitud,
    this.recogidaLongitud,
    this.recogidaInformacionAdicional,
    this.domicilioPiso,
    this.domicilioPuerta,
    this.domicilioDireccion,
    this.domicilioLatitud,
    this.domicilioLongitud,
    this.provinciaId,
    this.localidadId,
    this.centroHospitalarioId,
    this.facultativoId,
    this.mutuaAseguradora,
    this.numPoliza,
    this.consentimientoInformado,
    this.consentimientoInformadoFecha,
    this.consentimientoRgpd,
    this.consentimientoRgpdFecha,
    this.observaciones,
    this.activo,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  final String id;
  final String? identificacion;
  final String nombre;
  @JsonKey(name: 'primer_apellido')
  final String primerApellido;
  @JsonKey(name: 'segundo_apellido')
  final String? segundoApellido;
  @JsonKey(name: 'tipo_documento')
  final String tipoDocumento;
  /// Documento puede ser null en Supabase (partial unique index)
  final String? documento;
  @JsonKey(name: 'seguridad_social')
  final String? seguridadSocial;
  @JsonKey(name: 'num_historia')
  final String? numHistoria;
  final String sexo;
  @JsonKey(name: 'fecha_nacimiento')
  final String fechaNacimiento; // Guardado como String ISO en Supabase
  @JsonKey(name: 'telefono_movil')
  final String? telefonoMovil;
  @JsonKey(name: 'telefono_fijo')
  final String? telefonoFijo;
  final String? email;
  @JsonKey(name: 'pais_origen')
  final String? paisOrigen;
  final String? profesion;
  @JsonKey(name: 'recogida_lunes')
  final bool? recogidaLunes;
  @JsonKey(name: 'recogida_martes')
  final bool? recogidaMartes;
  @JsonKey(name: 'recogida_miercoles')
  final bool? recogidaMiercoles;
  @JsonKey(name: 'recogida_jueves')
  final bool? recogidaJueves;
  @JsonKey(name: 'recogida_viernes')
  final bool? recogidaViernes;
  @JsonKey(name: 'recogida_sabado')
  final bool? recogidaSabado;
  @JsonKey(name: 'recogida_domingo')
  final bool? recogidaDomingo;
  @JsonKey(name: 'recogida_festivos')
  final bool? recogidaFestivos;
  @JsonKey(name: 'recogida_piso')
  final String? recogidaPiso;
  @JsonKey(name: 'recogida_puerta')
  final String? recogidaPuerta;
  @JsonKey(name: 'recogida_latitud')
  final double? recogidaLatitud;
  @JsonKey(name: 'recogida_longitud')
  final double? recogidaLongitud;
  @JsonKey(name: 'recogida_informacion_adicional')
  final String? recogidaInformacionAdicional;
  @JsonKey(name: 'domicilio_piso')
  final String? domicilioPiso;
  @JsonKey(name: 'domicilio_puerta')
  final String? domicilioPuerta;
  @JsonKey(name: 'domicilio_direccion')
  final String? domicilioDireccion;
  @JsonKey(name: 'domicilio_latitud')
  final double? domicilioLatitud;
  @JsonKey(name: 'domicilio_longitud')
  final double? domicilioLongitud;
  @JsonKey(name: 'provincia_id')
  final String? provinciaId;
  @JsonKey(name: 'localidad_id')
  final String? localidadId;
  @JsonKey(name: 'centro_hospitalario_id')
  final String? centroHospitalarioId;
  @JsonKey(name: 'facultativo_id')
  final String? facultativoId;
  @JsonKey(name: 'mutua_aseguradora')
  final String? mutuaAseguradora;
  @JsonKey(name: 'num_poliza')
  final String? numPoliza;
  @JsonKey(name: 'consentimiento_informado')
  final bool? consentimientoInformado;
  @JsonKey(name: 'consentimiento_informado_fecha')
  final String? consentimientoInformadoFecha;
  @JsonKey(name: 'consentimiento_rgpd')
  final bool? consentimientoRgpd;
  @JsonKey(name: 'consentimiento_rgpd_fecha')
  final String? consentimientoRgpdFecha;
  final String? observaciones;
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
  factory PacienteSupabaseModel.fromJson(Map<String, dynamic> json) =>
      _$PacienteSupabaseModelFromJson(json);

  /// Serialización a JSON (Model → Supabase)
  Map<String, dynamic> toJson() => _$PacienteSupabaseModelToJson(this);

  /// Conversión desde Entity (Domain → Model)
  factory PacienteSupabaseModel.fromEntity(PacienteEntity entity) {
    return PacienteSupabaseModel(
      id: entity.id,
      identificacion: entity.identificacion,
      nombre: entity.nombre,
      primerApellido: entity.primerApellido,
      segundoApellido: entity.segundoApellido,
      tipoDocumento: entity.tipoDocumento,
      // Convertir string vacío a null para evitar violación de unique constraint
      documento: entity.documento.isEmpty ? null : entity.documento,
      seguridadSocial: entity.seguridadSocial,
      numHistoria: entity.numHistoria,
      sexo: entity.sexo,
      fechaNacimiento: entity.fechaNacimiento.toIso8601String().split('T').first,
      telefonoMovil: entity.telefonoMovil,
      telefonoFijo: entity.telefonoFijo,
      email: entity.email,
      paisOrigen: entity.paisOrigen,
      profesion: entity.profesion,
      recogidaLunes: entity.recogidaLunes,
      recogidaMartes: entity.recogidaMartes,
      recogidaMiercoles: entity.recogidaMiercoles,
      recogidaJueves: entity.recogidaJueves,
      recogidaViernes: entity.recogidaViernes,
      recogidaSabado: entity.recogidaSabado,
      recogidaDomingo: entity.recogidaDomingo,
      recogidaFestivos: entity.recogidaFestivos,
      recogidaPiso: entity.recogidaPiso,
      recogidaPuerta: entity.recogidaPuerta,
      recogidaLatitud: entity.recogidaLatitud,
      recogidaLongitud: entity.recogidaLongitud,
      recogidaInformacionAdicional: entity.recogidaInformacionAdicional,
      domicilioPiso: entity.domicilioPiso,
      domicilioPuerta: entity.domicilioPuerta,
      domicilioDireccion: entity.domicilioDireccion,
      domicilioLatitud: entity.domicilioLatitud,
      domicilioLongitud: entity.domicilioLongitud,
      provinciaId: entity.provinciaId,
      localidadId: entity.localidadId,
      centroHospitalarioId: entity.centroHospitalarioId,
      facultativoId: entity.facultativoId,
      mutuaAseguradora: entity.mutuaAseguradora,
      numPoliza: entity.numPoliza,
      consentimientoInformado: entity.consentimientoInformado,
      consentimientoInformadoFecha: entity.consentimientoInformadoFecha?.toIso8601String(),
      consentimientoRgpd: entity.consentimientoRgpd,
      consentimientoRgpdFecha: entity.consentimientoRgpdFecha?.toIso8601String(),
      observaciones: entity.observaciones,
      activo: entity.activo,
      createdAt: entity.createdAt?.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  /// Conversión a Entity (Model → Domain)
  PacienteEntity toEntity() {
    return PacienteEntity(
      id: id,
      identificacion: identificacion,
      nombre: nombre,
      primerApellido: primerApellido,
      segundoApellido: segundoApellido,
      tipoDocumento: tipoDocumento,
      // Convertir null a string vacío para la entity
      documento: documento ?? '',
      seguridadSocial: seguridadSocial,
      numHistoria: numHistoria,
      sexo: sexo,
      fechaNacimiento: DateTime.parse(fechaNacimiento),
      telefonoMovil: telefonoMovil,
      telefonoFijo: telefonoFijo,
      email: email,
      paisOrigen: paisOrigen,
      profesion: profesion,
      recogidaLunes: recogidaLunes ?? false,
      recogidaMartes: recogidaMartes ?? false,
      recogidaMiercoles: recogidaMiercoles ?? false,
      recogidaJueves: recogidaJueves ?? false,
      recogidaViernes: recogidaViernes ?? false,
      recogidaSabado: recogidaSabado ?? false,
      recogidaDomingo: recogidaDomingo ?? false,
      recogidaFestivos: recogidaFestivos ?? false,
      recogidaPiso: recogidaPiso,
      recogidaPuerta: recogidaPuerta,
      recogidaLatitud: recogidaLatitud,
      recogidaLongitud: recogidaLongitud,
      recogidaInformacionAdicional: recogidaInformacionAdicional,
      domicilioPiso: domicilioPiso,
      domicilioPuerta: domicilioPuerta,
      domicilioDireccion: domicilioDireccion,
      domicilioLatitud: domicilioLatitud,
      domicilioLongitud: domicilioLongitud,
      provinciaId: provinciaId,
      localidadId: localidadId,
      centroHospitalarioId: centroHospitalarioId,
      facultativoId: facultativoId,
      mutuaAseguradora: mutuaAseguradora,
      numPoliza: numPoliza,
      consentimientoInformado: consentimientoInformado ?? false,
      consentimientoInformadoFecha: consentimientoInformadoFecha != null
          ? DateTime.parse(consentimientoInformadoFecha!)
          : null,
      consentimientoRgpd: consentimientoRgpd ?? false,
      consentimientoRgpdFecha:
          consentimientoRgpdFecha != null ? DateTime.parse(consentimientoRgpdFecha!) : null,
      observaciones: observaciones,
      activo: activo ?? true,
      createdAt: createdAt != null ? DateTime.parse(createdAt!) : null,
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }
}
