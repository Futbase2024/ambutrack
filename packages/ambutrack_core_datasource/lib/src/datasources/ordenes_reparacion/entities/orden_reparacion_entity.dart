import 'package:equatable/equatable.dart';

import 'orden_reparacion_enums.dart';

/// Entity: Orden de reparación del taller
///
/// `numeroOrden` vacío en creación → lo genera un trigger en BD (OR-AAAA-NNNN).
/// `costoRepuestos` lo mantiene un trigger a partir de los repuestos.
/// `costoTotal` es columna generada (mano obra + repuestos + grúa).
/// `vehiculoMatricula` y `tallerNombre` son de solo lectura (joins).
class OrdenReparacionEntity extends Equatable {
  const OrdenReparacionEntity({
    required this.id,
    required this.empresaId,
    this.numeroOrden = '',
    required this.vehiculoId,
    this.tallerId,
    this.origen = OrigenOrdenReparacion.averia,
    this.incidenciaId,
    this.mantenimientoId,
    this.estado = EstadoOrdenReparacion.abierta,
    this.prioridad = PrioridadOrdenReparacion.normal,
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

  final String id;
  final String empresaId;
  final String numeroOrden;
  final String vehiculoId;
  final String? tallerId;
  final OrigenOrdenReparacion origen;
  final String? incidenciaId;
  final String? mantenimientoId;
  final EstadoOrdenReparacion estado;
  final PrioridadOrdenReparacion prioridad;
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

  // Solo lectura (joins)
  final String? vehiculoMatricula;
  final String? tallerNombre;

  OrdenReparacionEntity copyWith({
    String? vehiculoId,
    String? tallerId,
    OrigenOrdenReparacion? origen,
    String? incidenciaId,
    String? mantenimientoId,
    EstadoOrdenReparacion? estado,
    PrioridadOrdenReparacion? prioridad,
    String? diagnostico,
    String? trabajosRealizados,
    int? kilometrajeEntrada,
    int? kilometrajeSalida,
    String? mecanicoAsignado,
    String? mecanicoNombre,
    DateTime? fechaEntrada,
    double? manoObraHoras,
    double? costoManoObra,
    double? costoGrua,
    bool? cubiertoSeguro,
    int? garantiaMeses,
    DateTime? fechaFinGarantia,
    String? observaciones,
    DateTime? updatedAt,
  }) {
    return OrdenReparacionEntity(
      id: id,
      empresaId: empresaId,
      numeroOrden: numeroOrden,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      tallerId: tallerId ?? this.tallerId,
      origen: origen ?? this.origen,
      incidenciaId: incidenciaId ?? this.incidenciaId,
      mantenimientoId: mantenimientoId ?? this.mantenimientoId,
      estado: estado ?? this.estado,
      prioridad: prioridad ?? this.prioridad,
      diagnostico: diagnostico ?? this.diagnostico,
      trabajosRealizados: trabajosRealizados ?? this.trabajosRealizados,
      kilometrajeEntrada: kilometrajeEntrada ?? this.kilometrajeEntrada,
      kilometrajeSalida: kilometrajeSalida ?? this.kilometrajeSalida,
      mecanicoAsignado: mecanicoAsignado ?? this.mecanicoAsignado,
      mecanicoNombre: mecanicoNombre ?? this.mecanicoNombre,
      fechaEntrada: fechaEntrada ?? this.fechaEntrada,
      fechaInicioTrabajo: fechaInicioTrabajo,
      fechaEsperaRepuestos: fechaEsperaRepuestos,
      fechaFinalizacion: fechaFinalizacion,
      fechaCierre: fechaCierre,
      manoObraHoras: manoObraHoras ?? this.manoObraHoras,
      costoManoObra: costoManoObra ?? this.costoManoObra,
      costoRepuestos: costoRepuestos,
      costoGrua: costoGrua ?? this.costoGrua,
      costoTotal: costoTotal,
      cubiertoSeguro: cubiertoSeguro ?? this.cubiertoSeguro,
      garantiaMeses: garantiaMeses ?? this.garantiaMeses,
      fechaFinGarantia: fechaFinGarantia ?? this.fechaFinGarantia,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy,
      vehiculoMatricula: vehiculoMatricula,
      tallerNombre: tallerNombre,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        numeroOrden,
        vehiculoId,
        tallerId,
        origen,
        incidenciaId,
        mantenimientoId,
        estado,
        prioridad,
        diagnostico,
        trabajosRealizados,
        kilometrajeEntrada,
        kilometrajeSalida,
        mecanicoNombre,
        fechaEntrada,
        fechaInicioTrabajo,
        fechaEsperaRepuestos,
        fechaFinalizacion,
        fechaCierre,
        manoObraHoras,
        costoManoObra,
        costoRepuestos,
        costoGrua,
        costoTotal,
        cubiertoSeguro,
        garantiaMeses,
        fechaFinGarantia,
        observaciones,
        updatedAt,
        vehiculoMatricula,
        tallerNombre,
      ];
}
