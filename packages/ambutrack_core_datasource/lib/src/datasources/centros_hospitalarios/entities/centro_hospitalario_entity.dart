import '../../../core/base_entity.dart';

/// Entidad de Centro Hospitalario que extiende BaseEntity
class CentroHospitalarioEntity extends BaseEntity {
  const CentroHospitalarioEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    this.direccion,
    this.localidadId,
    this.localidadNombre,
    this.provinciaNombre,
    this.telefono,
    this.email,
    this.coordenadasGps,
    this.tipoCentro,
    this.especialidades,
    required this.activo,
  });

  final String nombre;
  final String? direccion;
  final String? localidadId;
  final String? localidadNombre;
  final String? provinciaNombre;
  final String? telefono;
  final String? email;
  final String? coordenadasGps;
  final String? tipoCentro;
  final List<String>? especialidades;
  final bool activo;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'nombre': nombre,
      if (direccion != null) 'direccion': direccion,
      if (localidadId != null) 'localidad_id': localidadId,
      if (localidadNombre != null) 'localidad_nombre': localidadNombre,
      if (provinciaNombre != null) 'provincia_nombre': provinciaNombre,
      if (telefono != null) 'telefono': telefono,
      if (email != null) 'email': email,
      if (coordenadasGps != null) 'coordenadas_gps': coordenadasGps,
      if (tipoCentro != null) 'tipo_centro': tipoCentro,
      if (especialidades != null) 'especialidades': especialidades,
      'activo': activo,
    };
  }

  @override
  CentroHospitalarioEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? nombre,
    String? direccion,
    String? localidadId,
    String? localidadNombre,
    String? provinciaNombre,
    String? telefono,
    String? email,
    String? coordenadasGps,
    String? tipoCentro,
    List<String>? especialidades,
    bool? activo,
  }) {
    return CentroHospitalarioEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      localidadId: localidadId ?? this.localidadId,
      localidadNombre: localidadNombre ?? this.localidadNombre,
      provinciaNombre: provinciaNombre ?? this.provinciaNombre,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      coordenadasGps: coordenadasGps ?? this.coordenadasGps,
      tipoCentro: tipoCentro ?? this.tipoCentro,
      especialidades: especialidades ?? this.especialidades,
      activo: activo ?? this.activo,
    );
  }
}
