import 'package:equatable/equatable.dart';

/// Tipos de proveedor
enum TipoProveedor {
  repuestos('repuestos', 'Repuestos'),
  servicios('servicios', 'Servicios'),
  lubricantes('lubricantes', 'Lubricantes'),
  neumaticos('neumaticos', 'Neumáticos'),
  otros('otros', 'Otros');

  const TipoProveedor(this.value, this.displayName);

  final String value;
  final String displayName;

  static TipoProveedor fromString(String value) {
    return TipoProveedor.values.firstWhere(
      (TipoProveedor e) => e.value == value,
      orElse: () => TipoProveedor.repuestos,
    );
  }
}

/// Entity: Proveedor de taller
class ProveedorTallerEntity extends Equatable {
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
  final TipoProveedor tipo;
  final String? formaPago;
  final String? cuentaBancaria;
  final bool activo;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProveedorTallerEntity({
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
    this.tipo = TipoProveedor.repuestos,
    this.formaPago,
    this.cuentaBancaria,
    this.activo = true,
    this.observaciones,
    required this.createdAt,
    this.updatedAt,
  });

  ProveedorTallerEntity copyWith({
    String? nombre,
    String? nif,
    String? direccion,
    String? ciudad,
    String? provincia,
    String? codigoPostal,
    String? telefono,
    String? email,
    String? contactoNombre,
    TipoProveedor? tipo,
    String? formaPago,
    String? cuentaBancaria,
    bool? activo,
    String? observaciones,
    DateTime? updatedAt,
  }) {
    return ProveedorTallerEntity(
      id: id,
      empresaId: empresaId,
      nombre: nombre ?? this.nombre,
      nif: nif ?? this.nif,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      provincia: provincia ?? this.provincia,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      contactoNombre: contactoNombre ?? this.contactoNombre,
      tipo: tipo ?? this.tipo,
      formaPago: formaPago ?? this.formaPago,
      cuentaBancaria: cuentaBancaria ?? this.cuentaBancaria,
      activo: activo ?? this.activo,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id];
}
