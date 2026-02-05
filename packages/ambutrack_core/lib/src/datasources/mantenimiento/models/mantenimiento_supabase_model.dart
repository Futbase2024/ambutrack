import '../entities/mantenimiento_entity.dart';

/// Model para interacción con Supabase (tabla tmantenimientos)
class MantenimientoSupabaseModel {
  const MantenimientoSupabaseModel({
    required this.id,
    required this.vehiculoId,
    required this.fecha,
    required this.kmVehiculo,
    required this.tipoMantenimiento,
    required this.descripcion,
    this.trabajosRealizados,
    this.taller,
    this.mecanicoResponsable,
    this.numeroOrden,
    this.costoManoObra,
    this.costoRepuestos,
    required this.costoTotal,
    required this.estado,
    this.fechaProgramada,
    this.fechaInicio,
    this.fechaFin,
    this.tiempoInoperativoHoras,
    this.proximoKmSugerido,
    this.proximaFechaSugerida,
    this.archivos,
    this.facturaUrl,
    required this.empresaId,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory MantenimientoSupabaseModel.fromJson(Map<String, dynamic> json) {
    return MantenimientoSupabaseModel(
      id: json['id'] as String,
      vehiculoId: json['vehiculo_id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      kmVehiculo: (json['km_vehiculo'] as num).toDouble(),
      tipoMantenimiento: TipoMantenimiento.fromString(json['tipo_mantenimiento'] as String),
      descripcion: json['descripcion'] as String,
      trabajosRealizados: json['trabajos_realizados'] as String?,
      taller: json['taller'] as String?,
      mecanicoResponsable: json['mecanico_responsable'] as String?,
      numeroOrden: json['numero_orden'] as String?,
      costoManoObra: json['costo_mano_obra'] != null
          ? (json['costo_mano_obra'] as num).toDouble()
          : null,
      costoRepuestos: json['costo_repuestos'] != null
          ? (json['costo_repuestos'] as num).toDouble()
          : null,
      costoTotal: (json['costo_total'] as num).toDouble(),
      estado: EstadoMantenimiento.fromString(json['estado'] as String),
      fechaProgramada: json['fecha_programada'] != null
          ? DateTime.parse(json['fecha_programada'] as String)
          : null,
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'] as String)
          : null,
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      tiempoInoperativoHoras: json['tiempo_inoperativo_horas'] != null
          ? (json['tiempo_inoperativo_horas'] as num).toDouble()
          : null,
      proximoKmSugerido: json['proximo_km_sugerido'] as int?,
      proximaFechaSugerida: json['proxima_fecha_sugerida'] != null
          ? DateTime.parse(json['proxima_fecha_sugerida'] as String)
          : null,
      archivos: json['archivos'] != null
          ? Map<String, dynamic>.from(json['archivos'] as Map)
          : null,
      facturaUrl: json['factura_url'] as String?,
      empresaId: json['empresa_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      updatedBy: json['updated_by'] as String?,
    );
  }

  factory MantenimientoSupabaseModel.fromEntity(MantenimientoEntity entity) {
    return MantenimientoSupabaseModel(
      id: entity.id,
      vehiculoId: entity.vehiculoId,
      fecha: entity.fecha,
      kmVehiculo: entity.kmVehiculo,
      tipoMantenimiento: entity.tipoMantenimiento,
      descripcion: entity.descripcion,
      trabajosRealizados: entity.trabajosRealizados,
      taller: entity.taller,
      mecanicoResponsable: entity.mecanicoResponsable,
      numeroOrden: entity.numeroOrden,
      costoManoObra: entity.costoManoObra,
      costoRepuestos: entity.costoRepuestos,
      costoTotal: entity.costoTotal,
      estado: entity.estado,
      fechaProgramada: entity.fechaProgramada,
      fechaInicio: entity.fechaInicio,
      fechaFin: entity.fechaFin,
      tiempoInoperativoHoras: entity.tiempoInoperativoHoras,
      proximoKmSugerido: entity.proximoKmSugerido,
      proximaFechaSugerida: entity.proximaFechaSugerida,
      archivos: entity.archivos,
      facturaUrl: entity.facturaUrl,
      empresaId: entity.empresaId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      updatedBy: entity.updatedBy,
    );
  }

  final String id;
  final String vehiculoId;
  final DateTime fecha;
  final double kmVehiculo;
  final TipoMantenimiento tipoMantenimiento;
  final String descripcion;
  final String? trabajosRealizados;
  final String? taller;
  final String? mecanicoResponsable;
  final String? numeroOrden;
  final double? costoManoObra;
  final double? costoRepuestos;
  final double costoTotal;
  final EstadoMantenimiento estado;
  final DateTime? fechaProgramada;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final double? tiempoInoperativoHoras;
  final int? proximoKmSugerido;
  final DateTime? proximaFechaSugerida;
  final Map<String, dynamic>? archivos;
  final String? facturaUrl;
  final String empresaId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'vehiculo_id': vehiculoId,
      'fecha': fecha.toIso8601String(),
      'km_vehiculo': kmVehiculo,
      'tipo_mantenimiento': tipoMantenimiento.name,
      'descripcion': descripcion,
      if (trabajosRealizados != null) 'trabajos_realizados': trabajosRealizados,
      if (taller != null) 'taller': taller,
      if (mecanicoResponsable != null) 'mecanico_responsable': mecanicoResponsable,
      if (numeroOrden != null) 'numero_orden': numeroOrden,
      if (costoManoObra != null) 'costo_mano_obra': costoManoObra,
      if (costoRepuestos != null) 'costo_repuestos': costoRepuestos,
      'costo_total': costoTotal,
      'estado': estado.toSupabaseValue(),
      if (fechaProgramada != null) 'fecha_programada': fechaProgramada!.toIso8601String(),
      if (fechaInicio != null) 'fecha_inicio': fechaInicio!.toIso8601String(),
      if (fechaFin != null) 'fecha_fin': fechaFin!.toIso8601String(),
      if (tiempoInoperativoHoras != null) 'tiempo_inoperativo_horas': tiempoInoperativoHoras,
      if (proximoKmSugerido != null) 'proximo_km_sugerido': proximoKmSugerido,
      if (proximaFechaSugerida != null) 'proxima_fecha_sugerida': proximaFechaSugerida!.toIso8601String(),
      if (archivos != null) 'archivos': archivos,
      if (facturaUrl != null) 'factura_url': facturaUrl,
      'empresa_id': empresaId,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
    };
  }

  MantenimientoEntity toEntity() {
    return MantenimientoEntity(
      id: id,
      vehiculoId: vehiculoId,
      fecha: fecha,
      kmVehiculo: kmVehiculo,
      tipoMantenimiento: tipoMantenimiento,
      descripcion: descripcion,
      trabajosRealizados: trabajosRealizados,
      taller: taller,
      mecanicoResponsable: mecanicoResponsable,
      numeroOrden: numeroOrden,
      costoManoObra: costoManoObra,
      costoRepuestos: costoRepuestos,
      costoTotal: costoTotal,
      estado: estado,
      fechaProgramada: fechaProgramada,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      tiempoInoperativoHoras: tiempoInoperativoHoras,
      proximoKmSugerido: proximoKmSugerido,
      proximaFechaSugerida: proximaFechaSugerida,
      archivos: archivos,
      facturaUrl: facturaUrl,
      empresaId: empresaId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }
}
