import 'package:equatable/equatable.dart';

/// Entidad de dominio para mantenimientos de vehículos
class MantenimientoEntity extends Equatable {
  const MantenimientoEntity({
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

  @override
  List<Object?> get props => <Object?>[
        id,
        vehiculoId,
        fecha,
        kmVehiculo,
        tipoMantenimiento,
        descripcion,
        trabajosRealizados,
        taller,
        mecanicoResponsable,
        numeroOrden,
        costoManoObra,
        costoRepuestos,
        costoTotal,
        estado,
        fechaProgramada,
        fechaInicio,
        fechaFin,
        tiempoInoperativoHoras,
        proximoKmSugerido,
        proximaFechaSugerida,
        archivos,
        facturaUrl,
        empresaId,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];

  MantenimientoEntity copyWith({
    String? id,
    String? vehiculoId,
    DateTime? fecha,
    double? kmVehiculo,
    TipoMantenimiento? tipoMantenimiento,
    String? descripcion,
    String? trabajosRealizados,
    String? taller,
    String? mecanicoResponsable,
    String? numeroOrden,
    double? costoManoObra,
    double? costoRepuestos,
    double? costoTotal,
    EstadoMantenimiento? estado,
    DateTime? fechaProgramada,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    double? tiempoInoperativoHoras,
    int? proximoKmSugerido,
    DateTime? proximaFechaSugerida,
    Map<String, dynamic>? archivos,
    String? facturaUrl,
    String? empresaId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return MantenimientoEntity(
      id: id ?? this.id,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      fecha: fecha ?? this.fecha,
      kmVehiculo: kmVehiculo ?? this.kmVehiculo,
      tipoMantenimiento: tipoMantenimiento ?? this.tipoMantenimiento,
      descripcion: descripcion ?? this.descripcion,
      trabajosRealizados: trabajosRealizados ?? this.trabajosRealizados,
      taller: taller ?? this.taller,
      mecanicoResponsable: mecanicoResponsable ?? this.mecanicoResponsable,
      numeroOrden: numeroOrden ?? this.numeroOrden,
      costoManoObra: costoManoObra ?? this.costoManoObra,
      costoRepuestos: costoRepuestos ?? this.costoRepuestos,
      costoTotal: costoTotal ?? this.costoTotal,
      estado: estado ?? this.estado,
      fechaProgramada: fechaProgramada ?? this.fechaProgramada,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      tiempoInoperativoHoras: tiempoInoperativoHoras ?? this.tiempoInoperativoHoras,
      proximoKmSugerido: proximoKmSugerido ?? this.proximoKmSugerido,
      proximaFechaSugerida: proximaFechaSugerida ?? this.proximaFechaSugerida,
      archivos: archivos ?? this.archivos,
      facturaUrl: facturaUrl ?? this.facturaUrl,
      empresaId: empresaId ?? this.empresaId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

/// Tipo de mantenimiento
enum TipoMantenimiento {
  basico,
  completo,
  especial,
  urgente;

  String get displayName {
    switch (this) {
      case TipoMantenimiento.basico:
        return 'Básico';
      case TipoMantenimiento.completo:
        return 'Completo';
      case TipoMantenimiento.especial:
        return 'Especial';
      case TipoMantenimiento.urgente:
        return 'Urgente';
    }
  }

  static TipoMantenimiento fromString(String value) {
    switch (value.toLowerCase()) {
      case 'basico':
        return TipoMantenimiento.basico;
      case 'completo':
        return TipoMantenimiento.completo;
      case 'especial':
        return TipoMantenimiento.especial;
      case 'urgente':
        return TipoMantenimiento.urgente;
      default:
        throw ArgumentError('Tipo de mantenimiento no válido: $value');
    }
  }
}

/// Estado del mantenimiento
enum EstadoMantenimiento {
  programado,
  enProceso,
  completado,
  cancelado;

  String get displayName {
    switch (this) {
      case EstadoMantenimiento.programado:
        return 'Programado';
      case EstadoMantenimiento.enProceso:
        return 'En Proceso';
      case EstadoMantenimiento.completado:
        return 'Completado';
      case EstadoMantenimiento.cancelado:
        return 'Cancelado';
    }
  }

  String toSupabaseValue() {
    switch (this) {
      case EstadoMantenimiento.programado:
        return 'programado';
      case EstadoMantenimiento.enProceso:
        return 'en_proceso';
      case EstadoMantenimiento.completado:
        return 'completado';
      case EstadoMantenimiento.cancelado:
        return 'cancelado';
    }
  }

  static EstadoMantenimiento fromString(String value) {
    switch (value.toLowerCase()) {
      case 'programado':
        return EstadoMantenimiento.programado;
      case 'en_proceso':
        return EstadoMantenimiento.enProceso;
      case 'completado':
        return EstadoMantenimiento.completado;
      case 'cancelado':
        return EstadoMantenimiento.cancelado;
      default:
        throw ArgumentError('Estado de mantenimiento no válido: $value');
    }
  }
}
