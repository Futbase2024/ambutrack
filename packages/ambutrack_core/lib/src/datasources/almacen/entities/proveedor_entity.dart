import 'package:ambutrack_core/src/core/base_entity.dart';

/// Entidad de dominio para Proveedor
///
/// Representa un proveedor de material médico y equipamiento
class ProveedorEntity extends BaseEntity {
  const ProveedorEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
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
  });

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

  @override
  List<Object?> get props => [
        ...super.props,
        codigo,
        nombreComercial,
        razonSocial,
        cifNif,
        direccion,
        codigoPostal,
        ciudad,
        provincia,
        pais,
        telefono,
        email,
        web,
        personaContacto,
        condicionesPago,
        descuentoGeneral,
        observaciones,
        activo,
        fechaAlta,
      ];

  @override
  ProveedorEntity copyWith({
    String? id,
    String? codigo,
    String? nombreComercial,
    String? razonSocial,
    String? cifNif,
    String? direccion,
    String? codigoPostal,
    String? ciudad,
    String? provincia,
    String? pais,
    String? telefono,
    String? email,
    String? web,
    String? personaContacto,
    String? condicionesPago,
    double? descuentoGeneral,
    String? observaciones,
    bool? activo,
    DateTime? fechaAlta,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProveedorEntity(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombreComercial: nombreComercial ?? this.nombreComercial,
      razonSocial: razonSocial ?? this.razonSocial,
      cifNif: cifNif ?? this.cifNif,
      direccion: direccion ?? this.direccion,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      ciudad: ciudad ?? this.ciudad,
      provincia: provincia ?? this.provincia,
      pais: pais ?? this.pais,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      web: web ?? this.web,
      personaContacto: personaContacto ?? this.personaContacto,
      condicionesPago: condicionesPago ?? this.condicionesPago,
      descuentoGeneral: descuentoGeneral ?? this.descuentoGeneral,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
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
      'fecha_alta': fechaAlta?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
