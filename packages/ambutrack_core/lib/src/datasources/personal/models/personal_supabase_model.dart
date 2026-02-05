import '../entities/personal_entity.dart';

/// Modelo DTO para serialización desde Supabase (tabla tpersonal)
///
/// Se encarga de convertir los datos JSON de Supabase a PersonalEntity.
class PersonalSupabaseModel {
  const PersonalSupabaseModel({
    required this.id,
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
    this.categoriaServicio,
    this.configuracionValidaciones,
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
  final DateTime? dataAnti;
  final bool? tesSiNo;
  final String? usuario;
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
  final Map<String, dynamic>? configuracionValidaciones;
  final String? categoria;

  /// Crea un modelo desde JSON de Supabase
  factory PersonalSupabaseModel.fromJson(Map<String, dynamic> json) {
    return PersonalSupabaseModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      apellidos: json['apellidos'] as String,
      dni: json['dni'] as String?,
      nass: json['nass'] as String?,
      direccion: json['direccion'] as String?,
      codigoPostal: json['codigo_postal'] as String?,
      telefono: json['telefono'] as String?,
      movil: json['movil'] as String?,
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'] as String)
          : null,
      fechaNacimiento: json['fecha_nacimiento'] != null
          ? DateTime.parse(json['fecha_nacimiento'] as String)
          : null,
      email: json['email'] as String?,
      dataAnti: json['data_anti'] != null
          ? DateTime.parse(json['data_anti'] as String)
          : null,
      tesSiNo: json['tes_si_no'] as bool?,
      usuario: json['usuario'] as String?,
      fechaAlta: json['fecha_alta'] != null
          ? DateTime.parse(json['fecha_alta'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      poblacionId: json['poblacion_id'] as String?,
      provinciaId: json['provincia_id'] as String?,
      puestoTrabajoId: json['puesto_trabajo_id'] as String?,
      contratoId: json['contrato_id'] as String?,
      empresaId: json['empresa_id'] as String?,
      categoriaId: json['categoria_id'] as String?,
      usuarioId: json['usuario_id'] as String?,
      createdBy: json['created_by'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      updatedBy: json['updated_by'] as String?,
      activo: json['activo'] as bool? ?? true,
      categoriaServicio: json['categoria_servicio'] as String?,
      configuracionValidaciones:
          json['configuracion_validaciones'] as Map<String, dynamic>?,
      categoria: json['categoria'] as String?,
    );
  }

  /// Convierte el modelo a JSON para Supabase
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
      'created_at': createdAt?.toIso8601String(),
      'poblacion_id': poblacionId,
      'provincia_id': provinciaId,
      'puesto_trabajo_id': puestoTrabajoId,
      'contrato_id': contratoId,
      'empresa_id': empresaId,
      'categoria_id': categoriaId,
      'usuario_id': usuarioId,
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
      'activo': activo,
      'categoria_servicio': categoriaServicio,
      'configuracion_validaciones': configuracionValidaciones,
      'categoria': categoria,
    };
  }

  /// Convierte el modelo a Entity de dominio
  PersonalEntity toEntity() {
    return PersonalEntity(
      id: id,
      nombre: nombre,
      apellidos: apellidos,
      dni: dni,
      nass: nass,
      direccion: direccion,
      codigoPostal: codigoPostal,
      telefono: telefono,
      movil: movil,
      fechaInicio: fechaInicio,
      fechaNacimiento: fechaNacimiento,
      email: email,
      dataAnti: dataAnti,
      tesSiNo: tesSiNo,
      usuario: usuario,
      fechaAlta: fechaAlta,
      createdAt: createdAt,
      poblacionId: poblacionId,
      provinciaId: provinciaId,
      puestoTrabajoId: puestoTrabajoId,
      contratoId: contratoId,
      empresaId: empresaId,
      categoriaId: categoriaId,
      usuarioId: usuarioId,
      createdBy: createdBy,
      updatedAt: updatedAt,
      updatedBy: updatedBy,
      activo: activo,
      categoriaServicio: categoriaServicio,
      configuracionValidaciones: configuracionValidaciones,
      categoria: categoria,
    );
  }

  /// Crea un modelo desde una Entity
  factory PersonalSupabaseModel.fromEntity(PersonalEntity entity) {
    return PersonalSupabaseModel(
      id: entity.id,
      nombre: entity.nombre,
      apellidos: entity.apellidos,
      dni: entity.dni,
      nass: entity.nass,
      direccion: entity.direccion,
      codigoPostal: entity.codigoPostal,
      telefono: entity.telefono,
      movil: entity.movil,
      fechaInicio: entity.fechaInicio,
      fechaNacimiento: entity.fechaNacimiento,
      email: entity.email,
      dataAnti: entity.dataAnti,
      tesSiNo: entity.tesSiNo,
      usuario: entity.usuario,
      fechaAlta: entity.fechaAlta,
      createdAt: entity.createdAt,
      poblacionId: entity.poblacionId,
      provinciaId: entity.provinciaId,
      puestoTrabajoId: entity.puestoTrabajoId,
      contratoId: entity.contratoId,
      empresaId: entity.empresaId,
      categoriaId: entity.categoriaId,
      usuarioId: entity.usuarioId,
      createdBy: entity.createdBy,
      updatedAt: entity.updatedAt,
      updatedBy: entity.updatedBy,
      activo: entity.activo,
      categoriaServicio: entity.categoriaServicio,
      configuracionValidaciones: entity.configuracionValidaciones,
      categoria: entity.categoria,
    );
  }
}
