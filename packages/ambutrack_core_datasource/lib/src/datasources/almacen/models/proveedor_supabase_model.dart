import '../entities/proveedor_entity.dart';

/// Modelo Supabase para Proveedor
///
/// DTO que mapea desde/hacia la tabla proveedores de PostgreSQL
class ProveedorSupabaseModel {
  const ProveedorSupabaseModel({
    required this.id,
    required this.codigo,
    required this.nombreComercial,
    this.razonSocial,
    this.cifNif,
    this.direccion,
    this.codigoPostal,
    this.ciudad,
    this.provincia,
    this.pais = 'España',
    this.telefono,
    this.email,
    this.web,
    this.personaContacto,
    this.condicionesPago,
    this.descuentoGeneral = 0,
    this.observaciones,
    required this.activo,
    this.fechaAlta,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String codigo;
  final String nombreComercial;
  final String? razonSocial;
  final String? cifNif;
  final String? direccion;
  final String? codigoPostal;
  final String? ciudad;
  final String? provincia;
  final String pais;
  final String? telefono;
  final String? email;
  final String? web;
  final String? personaContacto;
  final String? condicionesPago;
  final double descuentoGeneral;
  final String? observaciones;
  final bool activo;
  final DateTime? fechaAlta;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ProveedorSupabaseModel.fromJson(Map<String, dynamic> json) {
    return ProveedorSupabaseModel(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      nombreComercial: json['nombre_comercial'] as String,
      razonSocial: json['razon_social'] as String?,
      cifNif: json['cif_nif'] as String?,
      direccion: json['direccion'] as String?,
      codigoPostal: json['codigo_postal'] as String?,
      ciudad: json['ciudad'] as String?,
      provincia: json['provincia'] as String?,
      pais: json['pais'] as String? ?? 'España',
      telefono: json['telefono'] as String?,
      email: json['email'] as String?,
      web: json['web'] as String?,
      personaContacto: json['persona_contacto'] as String?,
      condicionesPago: json['condiciones_pago'] as String?,
      descuentoGeneral: (json['descuento_general'] as num?)?.toDouble() ?? 0,
      observaciones: json['observaciones'] as String?,
      activo: json['activo'] as bool,
      fechaAlta: json['fecha_alta'] != null ? DateTime.parse(json['fecha_alta'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'codigo': codigo,
      'nombre_comercial': nombreComercial,
      'razon_social': razonSocial,
      'cif_nif': cifNif,
      'direccion': direccion,
      'codigo_postal': codigoPostal,
      'ciudad': ciudad,
      'provincia': provincia,
      'pais': pais,
      'telefono': telefono,
      'email': email,
      'web': web,
      'persona_contacto': personaContacto,
      'condiciones_pago': condicionesPago,
      'descuento_general': descuentoGeneral,
      'observaciones': observaciones,
      'activo': activo,
      'fecha_alta': fechaAlta?.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convierte el modelo Supabase a entidad de dominio
  ProveedorEntity toEntity() {
    return ProveedorEntity(
      id: id,
      codigo: codigo,
      nombreComercial: nombreComercial,
      razonSocial: razonSocial,
      cifNif: cifNif,
      direccion: direccion,
      codigoPostal: codigoPostal,
      ciudad: ciudad,
      provincia: provincia,
      pais: pais,
      telefono: telefono,
      email: email,
      web: web,
      personaContacto: personaContacto,
      condicionesPago: condicionesPago,
      descuentoGeneral: descuentoGeneral,
      observaciones: observaciones,
      activo: activo,
      fechaAlta: fechaAlta,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convierte una entidad de dominio a modelo Supabase
  factory ProveedorSupabaseModel.fromEntity(ProveedorEntity entity) {
    return ProveedorSupabaseModel(
      id: entity.id,
      codigo: entity.codigo,
      nombreComercial: entity.nombreComercial,
      razonSocial: entity.razonSocial,
      cifNif: entity.cifNif,
      direccion: entity.direccion,
      codigoPostal: entity.codigoPostal,
      ciudad: entity.ciudad,
      provincia: entity.provincia,
      pais: entity.pais,
      telefono: entity.telefono,
      email: entity.email,
      web: entity.web,
      personaContacto: entity.personaContacto,
      condicionesPago: entity.condicionesPago,
      descuentoGeneral: entity.descuentoGeneral,
      observaciones: entity.observaciones,
      activo: entity.activo,
      fechaAlta: entity.fechaAlta,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
