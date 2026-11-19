import 'package:ambutrack_core_datasource/src/core/base_entity.dart';

/// Categorías de incidencia
enum CategoriaIncidencia {
  servicio,
  vehiculo,
  personal,
  instalacion,
  equipamiento,
  otro;

  String get displayName {
    switch (this) {
      case CategoriaIncidencia.servicio:
        return 'Servicio';
      case CategoriaIncidencia.vehiculo:
        return 'Vehículo';
      case CategoriaIncidencia.personal:
        return 'Personal';
      case CategoriaIncidencia.instalacion:
        return 'Instalación';
      case CategoriaIncidencia.equipamiento:
        return 'Equipamiento';
      case CategoriaIncidencia.otro:
        return 'Otro';
    }
  }

  static CategoriaIncidencia fromString(String value) {
    return CategoriaIncidencia.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => CategoriaIncidencia.otro,
    );
  }

  String toDbValue() => name;
}

/// Prioridad de la incidencia
enum PrioridadIncidencia {
  critica,
  alta,
  media,
  baja;

  String get displayName {
    switch (this) {
      case PrioridadIncidencia.critica:
        return 'Crítica';
      case PrioridadIncidencia.alta:
        return 'Alta';
      case PrioridadIncidencia.media:
        return 'Media';
      case PrioridadIncidencia.baja:
        return 'Baja';
    }
  }

  static PrioridadIncidencia fromString(String value) {
    return PrioridadIncidencia.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => PrioridadIncidencia.media,
    );
  }

  String toDbValue() => name;
}

/// Estado de la incidencia
enum EstadoIncidencia {
  reportada,
  enProceso,
  resuelta,
  cerrada;

  String get displayName {
    switch (this) {
      case EstadoIncidencia.reportada:
        return 'Reportada';
      case EstadoIncidencia.enProceso:
        return 'En Proceso';
      case EstadoIncidencia.resuelta:
        return 'Resuelta';
      case EstadoIncidencia.cerrada:
        return 'Cerrada';
    }
  }

  static EstadoIncidencia fromString(String value) {
    switch (value.toLowerCase()) {
      case 'reportada':
        return EstadoIncidencia.reportada;
      case 'en_proceso':
      case 'enproceso':
        return EstadoIncidencia.enProceso;
      case 'resuelta':
        return EstadoIncidencia.resuelta;
      case 'cerrada':
        return EstadoIncidencia.cerrada;
      default:
        return EstadoIncidencia.reportada;
    }
  }

  String toDbValue() {
    switch (this) {
      case EstadoIncidencia.reportada:
        return 'reportada';
      case EstadoIncidencia.enProceso:
        return 'en_proceso';
      case EstadoIncidencia.resuelta:
        return 'resuelta';
      case EstadoIncidencia.cerrada:
        return 'cerrada';
    }
  }
}

/// Entity para la tabla `incidencias`
class IncidenciaEntity extends BaseEntity {
  final String titulo;
  final String? descripcion;
  final CategoriaIncidencia categoria;
  final PrioridadIncidencia prioridad;
  final EstadoIncidencia estado;
  final DateTime fechaIncidencia;
  final String? responsableId;
  final String? responsableNombre;
  final String? reportadoPor;
  final String? reportadoPorNombre;
  final DateTime? fechaResolucion;
  final String? resolucion;
  final String? vehiculoId;
  final String? vehiculoMatricula;
  final String? empresaId;
  final String? createdBy;
  final String? updatedBy;

  const IncidenciaEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.titulo,
    this.descripcion,
    required this.categoria,
    required this.prioridad,
    required this.estado,
    required this.fechaIncidencia,
    this.responsableId,
    this.responsableNombre,
    this.reportadoPor,
    this.reportadoPorNombre,
    this.fechaResolucion,
    this.resolucion,
    this.vehiculoId,
    this.vehiculoMatricula,
    this.empresaId,
    this.createdBy,
    this.updatedBy,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        titulo,
        descripcion,
        categoria,
        prioridad,
        estado,
        fechaIncidencia,
        responsableId,
        responsableNombre,
        reportadoPor,
        reportadoPorNombre,
        fechaResolucion,
        resolucion,
        vehiculoId,
        vehiculoMatricula,
        empresaId,
        createdBy,
        updatedBy,
      ];

  @override
  IncidenciaEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? titulo,
    String? descripcion,
    CategoriaIncidencia? categoria,
    PrioridadIncidencia? prioridad,
    EstadoIncidencia? estado,
    DateTime? fechaIncidencia,
    String? responsableId,
    String? responsableNombre,
    String? reportadoPor,
    String? reportadoPorNombre,
    DateTime? fechaResolucion,
    String? resolucion,
    String? vehiculoId,
    String? vehiculoMatricula,
    String? empresaId,
    String? createdBy,
    String? updatedBy,
  }) {
    return IncidenciaEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      categoria: categoria ?? this.categoria,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      fechaIncidencia: fechaIncidencia ?? this.fechaIncidencia,
      responsableId: responsableId ?? this.responsableId,
      responsableNombre: responsableNombre ?? this.responsableNombre,
      reportadoPor: reportadoPor ?? this.reportadoPor,
      reportadoPorNombre: reportadoPorNombre ?? this.reportadoPorNombre,
      fechaResolucion: fechaResolucion ?? this.fechaResolucion,
      resolucion: resolucion ?? this.resolucion,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      vehiculoMatricula: vehiculoMatricula ?? this.vehiculoMatricula,
      empresaId: empresaId ?? this.empresaId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria.toDbValue(),
      'prioridad': prioridad.toDbValue(),
      'estado': estado.toDbValue(),
      'fecha_incidencia': fechaIncidencia.toIso8601String(),
      'responsable_id': responsableId,
      'responsable_nombre': responsableNombre,
      'reportado_por': reportadoPor,
      'reportado_por_nombre': reportadoPorNombre,
      'fecha_resolucion': fechaResolucion?.toIso8601String(),
      'resolucion': resolucion,
      'vehiculo_id': vehiculoId,
      'vehiculo_matricula': vehiculoMatricula,
      'empresa_id': empresaId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}
