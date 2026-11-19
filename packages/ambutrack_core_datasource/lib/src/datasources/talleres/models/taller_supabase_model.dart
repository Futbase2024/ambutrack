import '../entities/taller_entity.dart';

/// Model: Serialización JSON para ttalleres
class TallerSupabaseModel {
  TallerSupabaseModel({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.nif,
    this.direccion,
    this.ciudad,
    this.provincia,
    this.codigoPostal,
    this.telefono,
    this.email,
    this.contactoNombre,
    this.especialidad,
    this.tipo = 'propio',
    this.activo = true,
    this.observaciones,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String empresaId;
  final String nombre;
  final String? nif;
  final String? direccion;
  final String? ciudad;
  final String? provincia;
  final String? codigoPostal;
  final String? telefono;
  final String? email;
  final String? contactoNombre;
  final String? especialidad;
  final String tipo;
  final bool activo;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory TallerSupabaseModel.fromJson(Map<String, dynamic> json) {
    return TallerSupabaseModel(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      nombre: json['nombre'] as String,
      nif: json['nif'] as String?,
      direccion: json['direccion'] as String?,
      ciudad: json['ciudad'] as String?,
      provincia: json['provincia'] as String?,
      codigoPostal: json['codigo_postal'] as String?,
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      contactoNombre: json['contacto_nombre'] as String?,
      especialidad: json['especialidad'] as String?,
      tipo: json['tipo'] as String? ?? 'propio',
      activo: json['activo'] as bool? ?? true,
      observaciones: json['observaciones'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  factory TallerSupabaseModel.fromEntity(TallerEntity entity) {
    return TallerSupabaseModel(
      id: entity.id,
      empresaId: entity.empresaId,
      nombre: entity.nombre,
      nif: entity.nif,
      direccion: entity.direccion,
      ciudad: entity.ciudad,
      provincia: entity.provincia,
      codigoPostal: entity.codigoPostal,
      telefono: entity.telefono,
      email: entity.email,
      contactoNombre: entity.contactoNombre,
      especialidad: entity.especialidad,
      tipo: entity.tipo.value,
      activo: entity.activo,
      observaciones: entity.observaciones,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId,
      'nombre': nombre,
      if (nif != null) 'nif': nif,
      if (direccion != null) 'direccion': direccion,
      if (ciudad != null) 'ciudad': ciudad,
      if (provincia != null) 'provincia': provincia,
      if (codigoPostal != null) 'codigo_postal': codigoPostal,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      if (contactoNombre != null) 'contacto_nombre': contactoNombre,
      if (especialidad != null) 'especialidad': especialidad,
      'tipo': tipo,
      'activo': activo,
      if (observaciones != null) 'observaciones': observaciones,
    };
  }

  TallerEntity toEntity() {
    return TallerEntity(
      id: id,
      empresaId: empresaId,
      nombre: nombre,
      nif: nif,
      direccion: direccion,
      ciudad: ciudad,
      provincia: provincia,
      codigoPostal: codigoPostal,
      telefono: telefono,
      email: email,
      contactoNombre: contactoNombre,
      especialidad: especialidad,
      tipo: TipoTaller.fromString(tipo),
      activo: activo,
      observaciones: observaciones,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
