import 'package:equatable/equatable.dart';

/// Tipos de taller
enum TipoTaller {
  propio('propio', 'Propio'),
  externo('externo', 'Externo'),
  itv('itv', 'Estación ITV');

  const TipoTaller(this.value, this.displayName);

  final String value;
  final String displayName;

  static TipoTaller fromString(String value) {
    return TipoTaller.values.firstWhere(
      (TipoTaller e) => e.value == value,
      orElse: () => TipoTaller.propio,
    );
  }
}

/// Entity: Taller mecánico
class TallerEntity extends Equatable {
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
  final TipoTaller tipo;
  final bool activo;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TallerEntity({
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
    this.tipo = TipoTaller.propio,
    this.activo = true,
    this.observaciones,
    required this.createdAt,
    this.updatedAt,
  });

  TallerEntity copyWith({
    String? nombre,
    String? nif,
    String? direccion,
    String? ciudad,
    String? provincia,
    String? codigoPostal,
    String? telefono,
    String? email,
    String? contactoNombre,
    String? especialidad,
    TipoTaller? tipo,
    bool? activo,
    String? observaciones,
    DateTime? updatedAt,
  }) {
    return TallerEntity(
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
      especialidad: especialidad ?? this.especialidad,
      tipo: tipo ?? this.tipo,
      activo: activo ?? this.activo,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id];
}
