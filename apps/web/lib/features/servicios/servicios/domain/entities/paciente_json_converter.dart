import 'package:ambutrack_core/ambutrack_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

/// Converter personalizado para deserializar PacienteEntity desde JSON
///
/// Se usa porque PacienteEntity no tiene @JsonSerializable
class PacienteJsonConverter implements JsonConverter<PacienteEntity?, Map<String, dynamic>?> {
  const PacienteJsonConverter();

  @override
  PacienteEntity? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return PacienteEntity(
      id: json['id'] as String? ?? '',
      nombre: json['nombre'] as String? ?? '',
      primerApellido: json['primer_apellido'] as String? ?? '',
      segundoApellido: json['segundo_apellido'] as String?,
      tipoDocumento: json['tipo_documento'] as String? ?? 'DNI',
      documento: json['documento'] as String? ?? '',
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'] as String)
          : DateTime.now(),
      sexo: json['sexo'] as String? ?? 'HOMBRE',
      telefonoMovil: json['telefono_movil'] as String?,
      domicilioDireccion: json['domicilio_direccion'] as String?,
      localidadId: json['localidad_id'] as String?,
    );
  }

  @override
  Map<String, dynamic>? toJson(PacienteEntity? object) {
    if (object == null) {
      return null;
    }

    return <String, dynamic>{
      'id': object.id,
      'nombre': object.nombre,
      'primer_apellido': object.primerApellido,
      'segundo_apellido': object.segundoApellido,
      'tipo_documento': object.tipoDocumento,
      'documento': object.documento,
      'fecha_nacimiento': object.fechaNacimiento.toIso8601String(),
      'sexo': object.sexo,
      'telefono_movil': object.telefonoMovil,
      'domicilio_direccion': object.domicilioDireccion,
      'localidad_id': object.localidadId,
    };
  }
}
