import 'package:equatable/equatable.dart';

/// Tipo de incidencia del vehículo
enum TipoIncidencia {
  mecanica,
  electrica,
  carroceria,
  neumaticos,
  limpieza,
  equipamiento,
  documentacion,
  otra,
}

/// Extension para TipoIncidencia
extension TipoIncidenciaExtension on TipoIncidencia {
  String toJson() {
    return name;
  }

  static TipoIncidencia fromJson(String value) {
    return TipoIncidencia.values.firstWhere((e) => e.name == value);
  }

  String get nombre {
    switch (this) {
      case TipoIncidencia.mecanica:
        return 'Mecánica';
      case TipoIncidencia.electrica:
        return 'Eléctrica';
      case TipoIncidencia.carroceria:
        return 'Carrocería';
      case TipoIncidencia.neumaticos:
        return 'Neumáticos';
      case TipoIncidencia.limpieza:
        return 'Limpieza';
      case TipoIncidencia.equipamiento:
        return 'Equipamiento';
      case TipoIncidencia.documentacion:
        return 'Documentación';
      case TipoIncidencia.otra:
        return 'Otra';
    }
  }
}

/// Prioridad de la incidencia
enum PrioridadIncidencia {
  baja,
  media,
  alta,
  critica,
}

/// Extension para PrioridadIncidencia
extension PrioridadIncidenciaExtension on PrioridadIncidencia {
  String toJson() {
    return name;
  }

  static PrioridadIncidencia fromJson(String value) {
    return PrioridadIncidencia.values.firstWhere((e) => e.name == value);
  }

  String get nombre {
    switch (this) {
      case PrioridadIncidencia.baja:
        return 'Baja';
      case PrioridadIncidencia.media:
        return 'Media';
      case PrioridadIncidencia.alta:
        return 'Alta';
      case PrioridadIncidencia.critica:
        return 'Crítica';
    }
  }
}

/// Estado de la incidencia
enum EstadoIncidencia {
  reportada,
  enRevision,
  enReparacion,
  resuelta,
  cerrada,
}

/// Extension para EstadoIncidencia
extension EstadoIncidenciaExtension on EstadoIncidencia {
  String toJson() {
    switch (this) {
      case EstadoIncidencia.reportada:
        return 'reportada';
      case EstadoIncidencia.enRevision:
        return 'en_revision';
      case EstadoIncidencia.enReparacion:
        return 'en_reparacion';
      case EstadoIncidencia.resuelta:
        return 'resuelta';
      case EstadoIncidencia.cerrada:
        return 'cerrada';
    }
  }

  static EstadoIncidencia fromJson(String value) {
    switch (value) {
      case 'reportada':
        return EstadoIncidencia.reportada;
      case 'en_revision':
        return EstadoIncidencia.enRevision;
      case 'en_reparacion':
        return EstadoIncidencia.enReparacion;
      case 'resuelta':
        return EstadoIncidencia.resuelta;
      case 'cerrada':
        return EstadoIncidencia.cerrada;
      default:
        throw ArgumentError('Estado de incidencia no válido: $value');
    }
  }

  String get nombre {
    switch (this) {
      case EstadoIncidencia.reportada:
        return 'Reportada';
      case EstadoIncidencia.enRevision:
        return 'En Revisión';
      case EstadoIncidencia.enReparacion:
        return 'En Reparación';
      case EstadoIncidencia.resuelta:
        return 'Resuelta';
      case EstadoIncidencia.cerrada:
        return 'Cerrada';
    }
  }
}

/// Entity de incidencias de vehículos
class IncidenciaVehiculoEntity extends Equatable {
  /// ID único de la incidencia
  final String id;

  /// ID del vehículo afectado
  final String vehiculoId;

  /// ID del usuario que reporta la incidencia
  final String reportadoPor;

  /// Nombre completo del usuario que reporta (MAYÚSCULAS)
  final String reportadoPorNombre;

  /// Fecha y hora del reporte
  final DateTime fechaReporte;

  /// Tipo de incidencia
  final TipoIncidencia tipo;

  /// Prioridad de la incidencia
  final PrioridadIncidencia prioridad;

  /// Estado actual de la incidencia
  final EstadoIncidencia estado;

  /// Título breve de la incidencia (max 100 caracteres)
  final String titulo;

  /// Descripción detallada de la incidencia (max 500 caracteres)
  final String descripcion;

  /// Kilometraje del vehículo al momento del reporte
  final double? kilometrajeReporte;

  /// URLs de fotos adjuntas (máximo 5)
  final List<String>? fotosUrls;

  /// Ubicación GPS donde se reportó (JSON {lat, lng})
  final String? ubicacionReporte;

  // Campos de resolución

  /// ID del mecánico o usuario asignado para resolver
  final String? asignadoA;

  /// Fecha en que se asignó la incidencia
  final DateTime? fechaAsignacion;

  /// Fecha en que se resolvió la incidencia
  final DateTime? fechaResolucion;

  /// Descripción de la solución aplicada
  final String? solucionAplicada;

  /// Costo de la reparación
  final double? costoReparacion;

  /// Nombre del taller responsable de la reparación
  final String? tallerResponsable;

  /// ID de la empresa
  final String empresaId;

  /// Fecha de creación del registro
  final DateTime createdAt;

  /// Fecha de última actualización
  final DateTime? updatedAt;

  const IncidenciaVehiculoEntity({
    required this.id,
    required this.vehiculoId,
    required this.reportadoPor,
    required this.reportadoPorNombre,
    required this.fechaReporte,
    required this.tipo,
    required this.prioridad,
    required this.estado,
    required this.titulo,
    required this.descripcion,
    this.kilometrajeReporte,
    this.fotosUrls,
    this.ubicacionReporte,
    this.asignadoA,
    this.fechaAsignacion,
    this.fechaResolucion,
    this.solucionAplicada,
    this.costoReparacion,
    this.tallerResponsable,
    required this.empresaId,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        vehiculoId,
        reportadoPor,
        reportadoPorNombre,
        fechaReporte,
        tipo,
        prioridad,
        estado,
        titulo,
        descripcion,
        kilometrajeReporte,
        fotosUrls,
        ubicacionReporte,
        asignadoA,
        fechaAsignacion,
        fechaResolucion,
        solucionAplicada,
        costoReparacion,
        tallerResponsable,
        empresaId,
        createdAt,
        updatedAt,
      ];

  /// Crea una copia de la entity con campos modificados
  IncidenciaVehiculoEntity copyWith({
    String? id,
    String? vehiculoId,
    String? reportadoPor,
    String? reportadoPorNombre,
    DateTime? fechaReporte,
    TipoIncidencia? tipo,
    PrioridadIncidencia? prioridad,
    EstadoIncidencia? estado,
    String? titulo,
    String? descripcion,
    double? kilometrajeReporte,
    List<String>? fotosUrls,
    String? ubicacionReporte,
    String? asignadoA,
    DateTime? fechaAsignacion,
    DateTime? fechaResolucion,
    String? solucionAplicada,
    double? costoReparacion,
    String? tallerResponsable,
    String? empresaId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IncidenciaVehiculoEntity(
      id: id ?? this.id,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      reportadoPor: reportadoPor ?? this.reportadoPor,
      reportadoPorNombre: reportadoPorNombre ?? this.reportadoPorNombre,
      fechaReporte: fechaReporte ?? this.fechaReporte,
      tipo: tipo ?? this.tipo,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      kilometrajeReporte: kilometrajeReporte ?? this.kilometrajeReporte,
      fotosUrls: fotosUrls ?? this.fotosUrls,
      ubicacionReporte: ubicacionReporte ?? this.ubicacionReporte,
      asignadoA: asignadoA ?? this.asignadoA,
      fechaAsignacion: fechaAsignacion ?? this.fechaAsignacion,
      fechaResolucion: fechaResolucion ?? this.fechaResolucion,
      solucionAplicada: solucionAplicada ?? this.solucionAplicada,
      costoReparacion: costoReparacion ?? this.costoReparacion,
      tallerResponsable: tallerResponsable ?? this.tallerResponsable,
      empresaId: empresaId ?? this.empresaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'IncidenciaVehiculoEntity(id: $id, vehiculoId: $vehiculoId, tipo: $tipo, prioridad: $prioridad, estado: $estado, titulo: $titulo)';
  }
}
