import 'package:json_annotation/json_annotation.dart';

import '../entities/incidencia_vehiculo_entity.dart';

part 'incidencia_vehiculo_supabase_model.g.dart';

/// Modelo de datos para Incidencia de Vehículo en Supabase
@JsonSerializable(explicitToJson: true)
class IncidenciaVehiculoSupabaseModel {
  const IncidenciaVehiculoSupabaseModel({
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
    required this.updatedAt,
  });

  final String id;
  @JsonKey(name: 'vehiculo_id')
  final String vehiculoId;
  @JsonKey(name: 'reportado_por')
  final String reportadoPor;
  @JsonKey(name: 'reportado_por_nombre')
  final String reportadoPorNombre;
  @JsonKey(name: 'fecha_reporte')
  final DateTime fechaReporte;
  final String tipo;
  final String prioridad;
  final String estado;
  final String titulo;
  final String descripcion;
  @JsonKey(name: 'kilometraje_reporte')
  final double? kilometrajeReporte;
  @JsonKey(name: 'fotos_urls')
  final List<String>? fotosUrls;
  @JsonKey(name: 'ubicacion_reporte')
  final String? ubicacionReporte;
  @JsonKey(name: 'asignado_a')
  final String? asignadoA;
  @JsonKey(name: 'fecha_asignacion')
  final DateTime? fechaAsignacion;
  @JsonKey(name: 'fecha_resolucion')
  final DateTime? fechaResolucion;
  @JsonKey(name: 'solucion_aplicada')
  final String? solucionAplicada;
  @JsonKey(name: 'costo_reparacion')
  final double? costoReparacion;
  @JsonKey(name: 'taller_responsable')
  final String? tallerResponsable;
  @JsonKey(name: 'empresa_id')
  final String empresaId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  /// Deserialización desde JSON
  factory IncidenciaVehiculoSupabaseModel.fromJson(
          Map<String, dynamic> json) =>
      _$IncidenciaVehiculoSupabaseModelFromJson(json);

  /// Serialización a JSON
  Map<String, dynamic> toJson() =>
      _$IncidenciaVehiculoSupabaseModelToJson(this);

  /// Conversión a Entity
  IncidenciaVehiculoEntity toEntity() {
    return IncidenciaVehiculoEntity(
      id: id,
      vehiculoId: vehiculoId,
      reportadoPor: reportadoPor,
      reportadoPorNombre: reportadoPorNombre,
      fechaReporte: fechaReporte,
      tipo: TipoIncidenciaExtension.fromJson(tipo),
      prioridad: PrioridadIncidenciaExtension.fromJson(prioridad),
      estado: EstadoIncidenciaExtension.fromJson(estado),
      titulo: titulo,
      descripcion: descripcion,
      kilometrajeReporte: kilometrajeReporte,
      fotosUrls: fotosUrls,
      ubicacionReporte: ubicacionReporte,
      asignadoA: asignadoA,
      fechaAsignacion: fechaAsignacion,
      fechaResolucion: fechaResolucion,
      solucionAplicada: solucionAplicada,
      costoReparacion: costoReparacion,
      tallerResponsable: tallerResponsable,
      empresaId: empresaId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Conversión desde Entity
  factory IncidenciaVehiculoSupabaseModel.fromEntity(
      IncidenciaVehiculoEntity entity) {
    return IncidenciaVehiculoSupabaseModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      reportadoPor: entity.reportadoPor,
      reportadoPorNombre: entity.reportadoPorNombre,
      fechaReporte: entity.fechaReporte,
      tipo: entity.tipo.toJson(),
      prioridad: entity.prioridad.toJson(),
      estado: entity.estado.toJson(),
      titulo: entity.titulo,
      descripcion: entity.descripcion,
      kilometrajeReporte: entity.kilometrajeReporte,
      fotosUrls: entity.fotosUrls,
      ubicacionReporte: entity.ubicacionReporte,
      asignadoA: entity.asignadoA,
      fechaAsignacion: entity.fechaAsignacion,
      fechaResolucion: entity.fechaResolucion,
      solucionAplicada: entity.solucionAplicada,
      costoReparacion: entity.costoReparacion,
      tallerResponsable: entity.tallerResponsable,
      empresaId: entity.empresaId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt ?? DateTime.now(),
    );
  }
}
