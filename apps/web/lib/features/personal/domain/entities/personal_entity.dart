import 'package:ambutrack_web/features/personal/domain/entities/categoria_servicio.dart';
import 'package:ambutrack_web/features/personal/domain/entities/configuracion_validacion_entity.dart';
import 'package:equatable/equatable.dart';

/// Entidad de personal del dominio
class PersonalEntity extends Equatable {
  const PersonalEntity({
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
    this.empresa,
    this.pwdWeb,
    this.email,
    this.pwd,
    this.dataAnti,
    this.tesSiNo,
    this.usuario,
    this.fechaAlta,
    this.categoria,
    this.categoriaServicio = CategoriaServicio.programado,
    this.configuracionValidaciones,
    this.activo = true,
    this.poblacionId,
    this.provinciaId,
    this.puestoTrabajoId,
    this.contratoId,
    this.empresaId,
    this.categoriaId,
    this.usuarioId,
    required this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  /// Crea un PersonalEntity desde un Map (Supabase)
  factory PersonalEntity.fromMap(Map<String, dynamic> map) {
    try {
      return PersonalEntity(
        id: map['id']?.toString() ?? '',
        nombre: map['nombre']?.toString() ?? '',
        apellidos: map['apellidos']?.toString() ?? '',
        dni: map['dni']?.toString(),
        nass: map['nass']?.toString(),
        direccion: map['direccion']?.toString(),
        codigoPostal: map['codigo_postal']?.toString(),
        telefono: map['telefono']?.toString(),
        movil: map['movil']?.toString(),
        fechaInicio: map['fecha_inicio'] != null
            ? DateTime.parse(map['fecha_inicio'].toString())
            : null,
        fechaNacimiento: map['fecha_nacimiento'] != null
            ? DateTime.parse(map['fecha_nacimiento'].toString())
            : null,
        empresa: map['empresa']?.toString(),
        pwdWeb: map['pwd_web']?.toString(),
        email: map['email']?.toString(),
        pwd: map['pwd']?.toString(),
        dataAnti: map['data_anti'] != null
            ? DateTime.parse(map['data_anti'].toString())
            : null,
        tesSiNo: map['tes_si_no'] as bool?,
        usuario: map['usuario']?.toString(),
        fechaAlta: map['fecha_alta'] != null
            ? DateTime.parse(map['fecha_alta'].toString())
            : null,
        categoria: map['categoria']?.toString(),
        categoriaServicio: CategoriaServicio.fromString(map['categoria_servicio']?.toString()),
        configuracionValidaciones: map['configuracion_validaciones'] != null
            ? ConfiguracionValidacionEntity.fromJson(
                map['configuracion_validaciones'] as Map<String, dynamic>,
              )
            : null,
        activo: map['activo'] as bool? ?? true,
        poblacionId: map['poblacion_id']?.toString(),
        provinciaId: map['provincia_id']?.toString(),
        puestoTrabajoId: map['puesto_trabajo_id']?.toString(),
        contratoId: map['contrato_id']?.toString(),
        empresaId: map['empresa_id']?.toString(),
        categoriaId: map['categoria_id']?.toString(),
        usuarioId: map['usuario_id']?.toString(),
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'].toString())
            : DateTime.now(),
        createdBy: map['created_by']?.toString(),
        updatedAt: map['updated_at'] != null
            ? DateTime.parse(map['updated_at'].toString())
            : null,
        updatedBy: map['updated_by']?.toString(),
      );
    } catch (e) {
      throw Exception('Error al parsear PersonalEntity desde map: $e\nMap: $map');
    }
  }

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
  final String? empresa;
  final String? pwdWeb;
  final String? email;
  final String? pwd;
  final DateTime? dataAnti;
  final bool? tesSiNo;
  final String? usuario;
  final DateTime? fechaAlta;
  final String? categoria;
  final CategoriaServicio categoriaServicio;
  final ConfiguracionValidacionEntity? configuracionValidaciones;
  final bool activo;
  final String? poblacionId;
  final String? provinciaId;
  final String? puestoTrabajoId;
  final String? contratoId;
  final String? empresaId;
  final String? categoriaId;
  final String? usuarioId;
  final DateTime createdAt;
  final String? createdBy;
  final DateTime? updatedAt;
  final String? updatedBy;

  /// Nombre completo
  String get nombreCompleto => '$nombre $apellidos';

  /// Convierte el PersonalEntity a un Map para Supabase
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'nombre': nombre,
      'apellidos': apellidos,
      'dni': dni,
      'nass': nass,
      'direccion': direccion,
      'codigo_postal': codigoPostal,
      'telefono': telefono,
      'movil': movil,
      'fecha_inicio': fechaInicio?.toIso8601String().split('T')[0],
      'fecha_nacimiento': fechaNacimiento?.toIso8601String().split('T')[0],
      'pwd_web': pwdWeb,
      'email': email,
      'pwd': pwd,
      'data_anti': dataAnti?.toIso8601String().split('T')[0],
      'tes_si_no': tesSiNo,
      'usuario': usuario,
      'fecha_alta': fechaAlta?.toIso8601String().split('T')[0],
      'categoria_servicio': categoriaServicio.name,
      'configuracion_validaciones': configuracionValidaciones?.toJson(),
      'activo': activo,
      'poblacion_id': poblacionId,
      'provincia_id': provinciaId,
      'puesto_trabajo_id': puestoTrabajoId,
      'contrato_id': contratoId,
      'empresa_id': empresaId,
      'categoria_id': categoriaId,
      'usuario_id': usuarioId,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'updated_at': updatedAt?.toIso8601String(),
      'updated_by': updatedBy,
    };

    // Solo incluir el ID si no está vacío (para crear vs actualizar)
    if (id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }

  @override
  List<Object?> get props => <Object?>[
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
        empresa,
        pwdWeb,
        email,
        pwd,
        dataAnti,
        tesSiNo,
        usuario,
        fechaAlta,
        categoria,
        categoriaServicio,
        configuracionValidaciones,
        activo,
        poblacionId,
        provinciaId,
        puestoTrabajoId,
        contratoId,
        empresaId,
        categoriaId,
        usuarioId,
        createdAt,
        createdBy,
        updatedAt,
        updatedBy,
      ];
}
