import '../../../core/base_entity.dart';

/// Entity de dominio pura para el personal de AmbuTrack
///
/// Representa la información completa del personal sin acoplamientos a Supabase.
class PersonalEntity extends BaseEntity {
  const PersonalEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.nombre,
    required this.apellidos,
    required this.activo,
    this.dni,
    this.nass,
    this.direccion,
    this.codigoPostal,
    this.telefono,
    this.movil,
    this.fechaInicio,
    this.fechaNacimiento,
    this.email,
    this.dataAnti,
    this.tesSiNo,
    this.usuario,
    this.fechaAlta,
    this.poblacionId,
    this.provinciaId,
    this.puestoTrabajoId,
    this.contratoId,
    this.empresaId,
    this.categoriaId,
    this.usuarioId,
    this.createdBy,
    this.updatedBy,
    this.categoriaServicio,
    this.configuracionValidaciones,
    this.categoria,
  });

  /// Nombre del personal
  final String nombre;

  /// Apellidos del personal
  final String apellidos;

  /// DNI del personal
  final String? dni;

  /// Número de afiliación a la Seguridad Social
  final String? nass;

  /// Dirección del personal
  final String? direccion;

  /// Código postal
  final String? codigoPostal;

  /// Teléfono fijo
  final String? telefono;

  /// Teléfono móvil
  final String? movil;

  /// Fecha de inicio en la empresa
  final DateTime? fechaInicio;

  /// Fecha de nacimiento
  final DateTime? fechaNacimiento;

  /// Email del personal
  final String? email;

  /// Fecha de antigüedad
  final DateTime? dataAnti;

  /// Indica si es TES (Técnico en Emergencias Sanitarias)
  final bool? tesSiNo;

  /// Usuario del sistema legacy
  final String? usuario;

  /// Fecha de alta en el sistema
  final DateTime? fechaAlta;


  /// ID de la población
  final String? poblacionId;

  /// ID de la provincia
  final String? provinciaId;

  /// ID del puesto de trabajo
  final String? puestoTrabajoId;

  /// ID del tipo de contrato
  final String? contratoId;

  /// ID de la empresa
  final String? empresaId;

  /// ID de la categoría profesional
  final String? categoriaId;

  /// ID del usuario de autenticación (FK a auth.users)
  final String? usuarioId;

  /// ID del usuario que creó el registro
  final String? createdBy;


  /// ID del usuario que actualizó el registro
  final String? updatedBy;

  /// Indica si está activo
  final bool activo;

  /// Categoría de servicio (programado, urgente, etc.)
  final String? categoriaServicio;

  /// Configuración de validaciones (JSON)
  final Map<String, dynamic>? configuracionValidaciones;

  /// Categoría profesional (texto libre)
  final String? categoria;

  /// Nombre completo del personal
  String get nombreCompleto => '$nombre $apellidos';

  @override
  List<Object?> get props => [
        ...super.props,
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
        dataAnti,
        tesSiNo,
        usuario,
        fechaAlta,
        poblacionId,
        provinciaId,
        puestoTrabajoId,
        contratoId,
        empresaId,
        categoriaId,
        usuarioId,
        createdBy,
        updatedBy,
        activo,
        categoriaServicio,
        configuracionValidaciones,
        categoria,
      ];

  /// Copia la entidad con nuevos valores opcionales
  PersonalEntity copyWith({
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
    DateTime? dataAnti,
    bool? tesSiNo,
    String? usuario,
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
    Map<String, dynamic>? configuracionValidaciones,
    String? categoria,
  }) {
    return PersonalEntity(
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
      dataAnti: dataAnti ?? this.dataAnti,
      tesSiNo: tesSiNo ?? this.tesSiNo,
      usuario: usuario ?? this.usuario,
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
      configuracionValidaciones:
          configuracionValidaciones ?? this.configuracionValidaciones,
      categoria: categoria ?? this.categoria,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'dni': dni,
      'nass': nass,
      'direccion': direccion,
      'codigo_postal': codigoPostal,
      'telefono': telefono,
      'movil': movil,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'email': email,
      'data_anti': dataAnti?.toIso8601String(),
      'tes_si_no': tesSiNo,
      'usuario': usuario,
      'fecha_alta': fechaAlta?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'poblacion_id': poblacionId,
      'provincia_id': provinciaId,
      'puesto_trabajo_id': puestoTrabajoId,
      'contrato_id': contratoId,
      'empresa_id': empresaId,
      'categoria_id': categoriaId,
      'usuario_id': usuarioId,
      'created_by': createdBy,
      'updated_at': updatedAt.toIso8601String(),
      'updated_by': updatedBy,
      'activo': activo,
      'categoria_servicio': categoriaServicio,
      'configuracion_validaciones': configuracionValidaciones,
      'categoria': categoria,
    };
  }

  @override
  String toString() {
    return 'PersonalEntity(id: $id, nombreCompleto: $nombreCompleto, dni: $dni, categoria: $categoria, activo: $activo)';
  }
}
