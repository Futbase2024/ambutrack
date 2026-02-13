import 'package:equatable/equatable.dart';

/// Entidad que representa un registro de personal en la tabla tpersonal
///
/// Esta es la tabla legacy de personal que contiene los datos del personal
/// de las ambulancias. Se vincula con usuarios a través de usuario_id.
class TPersonalEntity extends Equatable {
  const TPersonalEntity({
    required this.id,
    required this.nombre,
    required this.apellidos,
    this.dni,
    this.nass,
    this.direccion,
    this.codigoPostal,
    this.telefono,
    this.movil,
    this.fechaInicio,
    this.fechaNacimiento,
    this.email,
    this.fechaAlta,
    this.createdAt,
    this.poblacionId,
    this.provinciaId,
    this.puestoTrabajoId,
    this.contratoId,
    this.empresaId,
    this.categoriaId,
    this.usuarioId,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.activo = true,
    this.categoriaServicio,
    this.categoria,
  });

  final String id;
  final String nombre;
  final String apellidos;
  final String? dni;
  final String? nass;
  final String? direccion;
  final String? codigoPostal;
  final String? telefono;
  final String? movil;
  final DateTime? fechaInicio;
  final DateTime? fechaNacimiento;
  final String? email;
  final DateTime? fechaAlta;
  final DateTime? createdAt;
  final String? poblacionId;
  final String? provinciaId;
  final String? puestoTrabajoId;
  final String? contratoId;
  final String? empresaId;
  final String? categoriaId;
  final String? usuarioId;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;
  final bool activo;
  final String? categoriaServicio;
  final String? categoria;

  /// Nombre completo del personal
  String get nombreCompleto => '$nombre $apellidos'.trim();

  @override
  List<Object?> get props => [
        id,
        nombre,
        apellidos,
        dni,
        nass,
        direccion,
        codigoPostal,
        telefono,
        movil,
        fechaInicio,
        fechaNacimiento,
        email,
        fechaAlta,
        createdAt,
        poblacionId,
        provinciaId,
        puestoTrabajoId,
        contratoId,
        empresaId,
        categoriaId,
        usuarioId,
        createdBy,
        updatedAt,
        updatedBy,
        activo,
        categoriaServicio,
        categoria,
      ];

  TPersonalEntity copyWith({
    String? id,
    String? nombre,
    String? apellidos,
    String? dni,
    String? nass,
    String? direccion,
    String? codigoPostal,
    String? telefono,
    String? movil,
    DateTime? fechaInicio,
    DateTime? fechaNacimiento,
    String? email,
    DateTime? fechaAlta,
    DateTime? createdAt,
    String? poblacionId,
    String? provinciaId,
    String? puestoTrabajoId,
    String? contratoId,
    String? empresaId,
    String? categoriaId,
    String? usuarioId,
    String? createdBy,
    DateTime? updatedAt,
    String? updatedBy,
    bool? activo,
    String? categoriaServicio,
    String? categoria,
  }) {
    return TPersonalEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      dni: dni ?? this.dni,
      nass: nass ?? this.nass,
      direccion: direccion ?? this.direccion,
      codigoPostal: codigoPostal ?? this.codigoPostal,
      telefono: telefono ?? this.telefono,
      movil: movil ?? this.movil,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      email: email ?? this.email,
      fechaAlta: fechaAlta ?? this.fechaAlta,
      createdAt: createdAt ?? this.createdAt,
      poblacionId: poblacionId ?? this.poblacionId,
      provinciaId: provinciaId ?? this.provinciaId,
      puestoTrabajoId: puestoTrabajoId ?? this.puestoTrabajoId,
      contratoId: contratoId ?? this.contratoId,
      empresaId: empresaId ?? this.empresaId,
      categoriaId: categoriaId ?? this.categoriaId,
      usuarioId: usuarioId ?? this.usuarioId,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      activo: activo ?? this.activo,
      categoriaServicio: categoriaServicio ?? this.categoriaServicio,
      categoria: categoria ?? this.categoria,
    );
  }
}
