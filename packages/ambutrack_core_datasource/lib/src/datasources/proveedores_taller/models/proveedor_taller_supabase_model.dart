import '../entities/proveedor_taller_entity.dart';

/// Model: Serialización JSON para tproveedores_taller
class ProveedorTallerSupabaseModel {
  ProveedorTallerSupabaseModel({
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
    this.tipo = 'repuestos',
    this.formaPago,
    this.cuentaBancaria,
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
  final String tipo;
  final String? formaPago;
  final String? cuentaBancaria;
  final bool activo;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory ProveedorTallerSupabaseModel.fromJson(Map<String, dynamic> json) {
    return ProveedorTallerSupabaseModel(
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
      tipo: json['tipo'] as String? ?? 'repuestos',
      formaPago: json['forma_pago'] as String?,
      cuentaBancaria: json['cuenta_bancaria'] as String?,
      activo: json['activo'] as bool? ?? true,
      observaciones: json['observaciones'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  factory ProveedorTallerSupabaseModel.fromEntity(ProveedorTallerEntity entity) {
    return ProveedorTallerSupabaseModel(
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
      tipo: entity.tipo.value,
      formaPago: entity.formaPago,
      cuentaBancaria: entity.cuentaBancaria,
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
      'tipo': tipo,
      if (formaPago != null) 'forma_pago': formaPago,
      if (cuentaBancaria != null) 'cuenta_bancaria': cuentaBancaria,
      'activo': activo,
      if (observaciones != null) 'observaciones': observaciones,
    };
  }

  ProveedorTallerEntity toEntity() {
    return ProveedorTallerEntity(
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
      tipo: TipoProveedor.fromString(tipo),
      formaPago: formaPago,
      cuentaBancaria: cuentaBancaria,
      activo: activo,
      observaciones: observaciones,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
