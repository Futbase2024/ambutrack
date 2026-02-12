import 'package:ambutrack_core/ambutrack_core.dart';
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
      ];
}

/// Estado de error
class HomeError extends HomeState {
  const HomeError({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}