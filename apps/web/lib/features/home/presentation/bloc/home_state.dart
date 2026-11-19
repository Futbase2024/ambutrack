import 'package:ambutrack_core_datasource/ambutrack_core_datasource.dart';
import 'package:equatable/equatable.dart';

/// Estados para HomeBloc
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => <Object?>[];
}

/// Estado inicial
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Estado de carga
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Estado con datos cargados
class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.isConnected,
    required this.vehiculosDisponibles,
    required this.totalVehiculos,
    required this.vehiculosEnServicio,
    required this.vehiculosMantenimiento,
    required this.serviciosActivos,
    required this.totalServicios,
    required this.serviciosProgramadosActivos,
    required this.serviciosProgramadosCompletados,
    required this.serviciosUrgenciasActivos,
    required this.serviciosUrgenciasCompletados,
    required this.serviciosTotalesDia,
    required this.serviciosCompletadosDia,
    required this.serviciosEnProceso,
    required this.vehiculosUrgenciasDisponibles,
    required this.vehiculosUrgenciasTotal,
    required this.vehiculosProgramadosDisponibles,
    required this.vehiculosProgramadosTotal,
    required this.mantenimientosProgramados,
    required this.mantenimientosEnProceso,
    required this.mantenimientosCompletados,
    required this.mantenimientosProximosOVencidos,
    // ─── Campos opcionales por rol (defaults = 0, sin breaking changes) ───
    this.incidenciasAbiertas = 0,
    this.ausenciasPendientes = 0,
    this.turnosHoy = 0,
    this.contratosVigentes = 0,
    this.itvProximasVencer = 0,
    this.ordenesAbiertas = 0,
    this.stockBajo = 0,
    this.misTurnosHoy = 0,
    this.misServiciosHoy = 0,
    this.misAusenciasActivas = 0,
  });

  final bool isConnected;
  final List<VehiculoEntity> vehiculosDisponibles;
  final int totalVehiculos;
  final int vehiculosEnServicio;
  final int vehiculosMantenimiento;
  final List<TrasladoEntity> serviciosActivos;
  final int totalServicios;

  // Métricas de resumen operacional
  final int serviciosProgramadosActivos;
  final int serviciosProgramadosCompletados;
  final int serviciosUrgenciasActivos;
  final int serviciosUrgenciasCompletados;

  // Métricas de estadísticas del día
  final int serviciosTotalesDia;
  final int serviciosCompletadosDia;
  final int serviciosEnProceso;

  // Métricas de flota
  final int vehiculosUrgenciasDisponibles;
  final int vehiculosUrgenciasTotal;
  final int vehiculosProgramadosDisponibles;
  final int vehiculosProgramadosTotal;

  // Métricas de mantenimientos preventivos (por estado)
  final int mantenimientosProgramados;
  final int mantenimientosEnProceso;
  final int mantenimientosCompletados;
  final List<MantenimientoEntity> mantenimientosProximosOVencidos;

  // ─── Datos por rol (cargados bajo demanda) ──────────────────────
  // Incidencias / RRHH
  final int incidenciasAbiertas;
  final int ausenciasPendientes;
  final int turnosHoy;

  // Administración
  final int contratosVigentes;

  // Taller / Mantenimiento
  final int itvProximasVencer;
  final int ordenesAbiertas;
  final int stockBajo;

  // Self-service (conductor / sanitario)
  final int misTurnosHoy;
  final int misServiciosHoy;
  final int misAusenciasActivas;

  @override
  List<Object?> get props => <Object?>[
        isConnected,
        vehiculosDisponibles,
        totalVehiculos,
        vehiculosEnServicio,
        vehiculosMantenimiento,
        serviciosActivos,
        totalServicios,
        serviciosProgramadosActivos,
        serviciosProgramadosCompletados,
        serviciosUrgenciasActivos,
        serviciosUrgenciasCompletados,
        serviciosTotalesDia,
        serviciosCompletadosDia,
        serviciosEnProceso,
        vehiculosUrgenciasDisponibles,
        vehiculosUrgenciasTotal,
        vehiculosProgramadosDisponibles,
        vehiculosProgramadosTotal,
        mantenimientosProgramados,
        mantenimientosEnProceso,
        mantenimientosCompletados,
        mantenimientosProximosOVencidos,
        incidenciasAbiertas,
        ausenciasPendientes,
        turnosHoy,
        contratosVigentes,
        itvProximasVencer,
        ordenesAbiertas,
        stockBajo,
        misTurnosHoy,
        misServiciosHoy,
        misAusenciasActivas,
      ];
}

/// Estado de error
class HomeError extends HomeState {
  const HomeError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}