import '../entities/orden_reparacion_entity.dart';
import '../entities/orden_reparacion_enums.dart';

DateTime? _date(dynamic value) => value == null ? null : DateTime.parse(value as String);

String? _iso(DateTime? value) => value?.toUtc().toIso8601String();

double _num(dynamic value) => (value as num?)?.toDouble() ?? 0;

String? _joined(dynamic relation, String field) =>
    relation is Map<String, dynamic> ? relation[field] as String? : null;

/// Model: Serialización JSON para tordenes_reparacion
class OrdenReparacionSupabaseModel {
  OrdenReparacionSupabaseModel({
    required this.id,
    required this.empresaId,
    required this.numeroOrden,
    required this.vehiculoId,
    this.tallerId,
    this.origen = 'averia',
    this.incidenciaId,
    this.mantenimientoId,
    this.estado = 'abierta',
    this.prioridad = 'normal',
    this.diagnostico,
    this.trabajosRealizados,
    this.kilometrajeEntrada,
    this.kilometrajeSalida,
    this.mecanicoAsignado,
    this.mecanicoNombre,
    required this.fechaEntrada,
    this.fechaInicioTrabajo,
    this.fechaEsperaRepuestos,
    this.fechaFinalizacion,
    this.fechaCierre,
    this.manoObraHoras = 0,
    this.costoManoObra = 0,
    this.costoRepuestos = 0,
    this.costoGrua = 0,
    this.costoTotal = 0,
    this.cubiertoSeguro = false,
    this.garantiaMeses,
    this.fechaFinGarantia,
    this.observaciones,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.vehiculoMatricula,
    this.tallerNombre,
  });

  /// Select con joins para mostrar matrícula y nombre del taller
  static const String selectWithJoins =
      '*, vehiculo:tvehiculos(matricula), taller:ttalleres(nombre)';

  final String id;
  final String empresaId;
  final String numeroOrden;
  final String vehiculoId;
  final String? tallerId;
  final String origen;
  final String? incidenciaId;
  final String? mantenimientoId;
  final String estado;
  final String prioridad;
  final String? diagnostico;
  final String? trabajosRealizados;
  final int? kilometrajeEntrada;
  final int? kilometrajeSalida;
  final String? mecanicoAsignado;
  final String? mecanicoNombre;
  final DateTime fechaEntrada;
  final DateTime? fechaInicioTrabajo;
  final DateTime? fechaEsperaRepuestos;
  final DateTime? fechaFinalizacion;
  final DateTime? fechaCierre;
  final double manoObraHoras;
  final double costoManoObra;
  final double costoRepuestos;
  final double costoGrua;
  final double costoTotal;
  final bool cubiertoSeguro;
  final int? garantiaMeses;
  final DateTime? fechaFinGarantia;
  final String? observaciones;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? vehiculoMatricula;
  final String? tallerNombre;

  factory OrdenReparacionSupabaseModel.fromJson(Map<String, dynamic> json) {
    return OrdenReparacionSupabaseModel(
      id: json['id'] as String,
      empresaId: json['empresa_id'] as String,
      numeroOrden: json['numero_orden'] as String? ?? '',
      vehiculoId: json['vehiculo_id'] as String,
      tallerId: json['taller_id'] as String?,
      origen: json['origen'] as String? ?? 'averia',
      incidenciaId: json['incidencia_id'] as String?,
      mantenimientoId: json['mantenimiento_id'] as String?,
      estado: json['estado'] as String? ?? 'abierta',
      prioridad: json['prioridad'] as String? ?? 'normal',
      diagnostico: json['diagnostico'] as String?,
      trabajosRealizados: json['trabajos_realizados'] as String?,
      kilometrajeEntrada: (json['kilometraje_entrada'] as num?)?.toInt(),
      kilometrajeSalida: (json['kilometraje_salida'] as num?)?.toInt(),
      mecanicoAsignado: json['mecanico_asignado'] as String?,
      mecanicoNombre: json['mecanico_nombre'] as String?,
      fechaEntrada: DateTime.parse(json['fecha_entrada'] as String),
      fechaInicioTrabajo: _date(json['fecha_inicio_trabajo']),
      fechaEsperaRepuestos: _date(json['fecha_espera_repuestos']),
      fechaFinalizacion: _date(json['fecha_finalizacion']),
      fechaCierre: _date(json['fecha_cierre']),
      manoObraHoras: _num(json['mano_obra_horas']),
      costoManoObra: _num(json['costo_mano_obra']),
      costoRepuestos: _num(json['costo_repuestos']),
      costoGrua: _num(json['costo_grua']),
      costoTotal: _num(json['costo_total']),
      cubiertoSeguro: json['cubierto_seguro'] as bool? ?? false,
      garantiaMeses: (json['garantia_meses'] as num?)?.toInt(),
      fechaFinGarantia: _date(json['fecha_fin_garantia']),
      observaciones: json['observaciones'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: _date(json['updated_at']),
      createdBy: json['created_by'] as String?,
      vehiculoMatricula: _joined(json['vehiculo'], 'matricula'),
      tallerNombre: _joined(json['taller'], 'nombre'),
    );
  }

  factory OrdenReparacionSupabaseModel.fromEntity(OrdenReparacionEntity e) {
    return OrdenReparacionSupabaseModel(
      id: e.id,
      empresaId: e.empresaId,
      numeroOrden: e.numeroOrden,
      vehiculoId: e.vehiculoId,
      tallerId: e.tallerId,
      origen: e.origen.value,
      incidenciaId: e.incidenciaId,
      mantenimientoId: e.mantenimientoId,
      estado: e.estado.value,
      prioridad: e.prioridad.value,
      diagnostico: e.diagnostico,
      trabajosRealizados: e.trabajosRealizados,
      kilometrajeEntrada: e.kilometrajeEntrada,
      kilometrajeSalida: e.kilometrajeSalida,
      mecanicoAsignado: e.mecanicoAsignado,
      mecanicoNombre: e.mecanicoNombre,
      fechaEntrada: e.fechaEntrada,
      fechaInicioTrabajo: e.fechaInicioTrabajo,
      fechaEsperaRepuestos: e.fechaEsperaRepuestos,
      fechaFinalizacion: e.fechaFinalizacion,
      fechaCierre: e.fechaCierre,
      manoObraHoras: e.manoObraHoras,
      costoManoObra: e.costoManoObra,
      costoRepuestos: e.costoRepuestos,
      costoGrua: e.costoGrua,
      costoTotal: e.costoTotal,
      cubiertoSeguro: e.cubiertoSeguro,
      garantiaMeses: e.garantiaMeses,
      fechaFinGarantia: e.fechaFinGarantia,
      observaciones: e.observaciones,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      createdBy: e.createdBy,
    );
  }

  /// JSON para insert/update.
  /// Excluye columnas generadas (costo_total), mantenidas por trigger
  /// (costo_repuestos), timestamps y numero_orden vacío (lo genera el trigger).
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'empresa_id': empresaId,
      if (numeroOrden.isNotEmpty) 'numero_orden': numeroOrden,
      'vehiculo_id': vehiculoId,
      'taller_id': tallerId,
      'origen': origen,
      'incidencia_id': incidenciaId,
      'mantenimiento_id': mantenimientoId,
      'estado': estado,
      'prioridad': prioridad,
      'diagnostico': diagnostico,
      'trabajos_realizados': trabajosRealizados,
      'kilometraje_entrada': kilometrajeEntrada,
      'kilometraje_salida': kilometrajeSalida,
      'mecanico_asignado': mecanicoAsignado,
      'mecanico_nombre': mecanicoNombre,
      'fecha_entrada': _iso(fechaEntrada),
      'fecha_inicio_trabajo': _iso(fechaInicioTrabajo),
      'fecha_espera_repuestos': _iso(fechaEsperaRepuestos),
      'fecha_finalizacion': _iso(fechaFinalizacion),
      'fecha_cierre': _iso(fechaCierre),
      'mano_obra_horas': manoObraHoras,
      'costo_mano_obra': costoManoObra,
      'costo_grua': costoGrua,
      'cubierto_seguro': cubiertoSeguro,
      'garantia_meses': garantiaMeses,
      'fecha_fin_garantia': _iso(fechaFinGarantia),
      'observaciones': observaciones,
      if (createdBy != null) 'created_by': createdBy,
    };
  }

  OrdenReparacionEntity toEntity() {
    return OrdenReparacionEntity(
      id: id,
      empresaId: empresaId,
      numeroOrden: numeroOrden,
      vehiculoId: vehiculoId,
      tallerId: tallerId,
      origen: OrigenOrdenReparacion.fromString(origen),
      incidenciaId: incidenciaId,
      mantenimientoId: mantenimientoId,
      estado: EstadoOrdenReparacion.fromString(estado),
      prioridad: PrioridadOrdenReparacion.fromString(prioridad),
      diagnostico: diagnostico,
      trabajosRealizados: trabajosRealizados,
      kilometrajeEntrada: kilometrajeEntrada,
      kilometrajeSalida: kilometrajeSalida,
      mecanicoAsignado: mecanicoAsignado,
      mecanicoNombre: mecanicoNombre,
      fechaEntrada: fechaEntrada,
      fechaInicioTrabajo: fechaInicioTrabajo,
      fechaEsperaRepuestos: fechaEsperaRepuestos,
      fechaFinalizacion: fechaFinalizacion,
      fechaCierre: fechaCierre,
      manoObraHoras: manoObraHoras,
      costoManoObra: costoManoObra,
      costoRepuestos: costoRepuestos,
      costoGrua: costoGrua,
      costoTotal: costoTotal,
      cubiertoSeguro: cubiertoSeguro,
      garantiaMeses: garantiaMeses,
      fechaFinGarantia: fechaFinGarantia,
      observaciones: observaciones,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      vehiculoMatricula: vehiculoMatricula,
      tallerNombre: tallerNombre,
    );
  }
}
